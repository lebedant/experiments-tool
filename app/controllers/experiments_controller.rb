require 'histogram/array'

class ExperimentsController < ApplicationController
  allowed_ghost_actions [:to_test, :to_edit, :to_open, :to_closed]
  before_action :set_experiment, except: [:new, :create, :index]
  before_action :check_state, only: [:edit, :update]
  add_breadcrumb I18n.t(:experiment_plural), :experiments_path


  def colors
    [
      "rgba(20,220,220,0.3)",
      "rgba(30,240,120,0.3)",
      "rgba(40,120,200,0.3)",
      "rgba(120,220,220,0.3)",
      "rgba(20,220,220,0.3)"
    ]
  end

  # GET /experiments
  # GET /experiments.json
  def index
    @experiments = Experiment.page(params[:page])
  end

  # GET /experiments/1
  # GET /experiments/1.json
  def show
    add_breadcrumb "#{@experiment.name}", @experiment

    # boxplot form preparations
    prepare_boxplot_form

    # Grouped select options for all variables (grouped by part)
    @grouped_variables = {}
    @experiment.parts.each do |part|
      @grouped_variables[part.name] = part.variables.pluck(:name, :id)
    end

    # Histogram chart for check data
    prepare_data_for_var(params[:chart_variable]) if params[:chart_variable].present?

    # Boxplots hash
    @boxplots = {}

    @experiment.chart_definitions.each do |definition|
      # Boxplot chart
      @boxplots[definition.name.parameterize] = prepare_boxplot_data(
                                        definition.target_variable,
                                        definition.filter_variable,
                                        definition.filter_variable_values
                                       )
    end

    #
    respond_to do |format|
      format.html {}
      # Download as json
      format.json {
        file_name = "#{@experiment.name.parameterize.underscore}"
        flash[:notice] = 'Experiment was successfully exported.'
        content = @experiment.to_json
        send_data content, filename: "#{file_name}.json"
      }
    end
  end

  # GET /experiments/new
  def new
    @experiment = Experiment.new(user: current_user)
    @experiment.parts.build
    add_breadcrumb t(:new_experiment_breadcrumb), new_experiment_path
  end

  # GET /experiments/1/edit
  def edit
    add_breadcrumb "#{@experiment.name}", @experiment
    add_breadcrumb t(:edit_breadcrumb), edit_experiment_path(@experiment)
  end

  # POST /experiments
  # POST /experiments.json
  def create
    add_breadcrumb t(:new_experiment_breadcrumb), {}
    @experiment = Experiment.new(experiment_params)
    @experiment.user = current_user

    respond_to do |format|
      if @experiment.save
        format.html {
          flash[:notice] = 'Experiment was successfully created.'
          redirect_to @experiment
        }
        format.json { render :show, status: :created, location: @experiment }
      else
        format.html { render :new }
        format.json { render json: @experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /experiments/1
  # PATCH/PUT /experiments/1.json
  def update
    respond_to do |format|
      if @experiment.update(experiment_params)
        format.html {
          flash[:notice] = 'Experiment was successfully updated.'
          redirect_to @experiment
        }
        format.json { render :show, status: :ok, location: @experiment }
      else
        format.html { render :edit }
        format.json { render json: @experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /experiments/1
  # DELETE /experiments/1.json
  def destroy
    @experiment.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = 'Experiment was successfully destroyed.'
        redirect_to experiments_url
      }
      format.json { head :no_content }
    end
  end

  # POST /experiments/1/copy
  # POST /experiments/1/copy.json
  def copy
    new_experiment = @experiment.amoeba_dup

    respond_to do |format|
      if new_experiment.save
        format.html {
          flash[:notice] = 'Experiment was successfully duplicated.'
          redirect_to new_experiment
        }
        format.json { render :show, status: :ok, location: new_experiment }
      else
        format.html {
          flash[:notice] = new_experiment.errors.full_messages.join(', ')
          redirect_to @experiment
        }
        format.json { render json: new_experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  #
  # If the action exists and is included in the allowed actions then is dynamically loaded.
  #
  def action_missing(name)
    begin
      self.send name
    rescue
      super
    end
  end

  def change_state(transition)
    if @experiment.send transition
      flash[:notice] = 'Experiment state was successfully changed.'
    else
      flash[:alert] = 'Invalid experiment state transition.'
    end
    redirect_to @experiment
  end

  #
  # As the action will call the method, it's necessary to handle the behavior if this method doesn't exist.
  #
  def method_missing(name, *args, &block)
    return change_state(name) if respond_to?(name, true)
    super
  end

  def to_experiment
    if @experiment.to_experiment
      flash[:notice] = 'Experiment state was successfully changed.'
    else
      flash[:alert] = 'Invalid experiment state transition.'
    end
    redirect_to @experiment
  end

  private

    def prepare_boxplot_form
      @definition = ChartDefinition.new(experiment_id: @experiment.id)
      @target_vars = @experiment.variables.not_strings.pluck(:name).uniq
      @filter_vars = @experiment.variables.strings.pluck(:name).uniq
      @calculate_methods = [:log_transform, :normal_distribution, :binominal_distribution]

      @filter_values = {}

      @filter_vars.each do |variable_name|
        @filter_values[variable_name] = @experiment.json_data
                                                   .pluck("data ->> '#{variable_name}'")
                                                   .uniq
        @filter_values[variable_name] << "all"
      end
    end

    def prepare_data_for_var(variable_id)
      variable = Experiment::Variable.find(variable_id)
      # can't work with no data
      if variable.data.blank?
        # flash[:error] = 'This variable has no data yet.'
        return
      end
      # histogram plot
      x,y = variable.data.histogram(bin_width: 1.0)
      pairs = x.zip(y)
      @histogram_data = [variable.name]
      @histogram_data << pairs.map { |value, count| { x: value.round(3), y: count } }
    end

    def prepare_boxplot_data(target_var_name, filter_var_name, filter_var_values)
      target_var = Experiment::Variable.where(name: target_var_name).first
      filter_var = Experiment::Variable.where(name: filter_var_name).first

      x_labels = filter_var_values.reject(&:blank?).map { |value| "#{filter_var.name} #{value}" }

      return if x_labels.empty?

      # labels from filter_variable
      boxplot_data = { labels: x_labels, datasets: [] }
      # for color
      i = 0

      @experiment.parts.each do |part|
        means,uppers,lowers = calculate_means_for(part, target_var, filter_var, filter_var_values)

        boxplot_data[:datasets] << {
                            label: part.name, # legend name => part name
                            backgroundColor: colors[i],
                            data:  means,
                            error: means.map{|m|  m / 10}
                          }
        i += 1
      end

      boxplot_data
    end

    def calculate_means_for(part, target_var, filter_var, filter_var_values)
      means = []
      uppers = []
      lowers = []

      filter_var_values.each do |value|
        next if value.empty?
        scope = part.json_data
        scope = scope.where("data ->> '#{filter_var.name}' = ?", value.to_s) unless value == "all"
        scope = scope.pluck("data -> '#{target_var.name}'")
        # type casting
        data_array = target_var.long? ? scope.map(&:to_i) : scope.map(&:to_f)
        # calculate
        mean,upper,lower = mean_and_error_for(data_array)
        # pushh to result arrays
        means  << mean
        uppers << upper
        lowers << lower
      end
      # return multiple values
      [means, uppers, lowers]
    end

    def mean_and_error_for(data)
      mean  = data.sum / data.size
      upper = mean + 2
      lower = mean - 3
    end

    # ----------------------------------------

    def check_state
      if !@experiment.edit?
        flash[:alert] = 'Editation is closed.'
        redirect_to @experiment
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_experiment
      @experiment = Experiment.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def experiment_params
      params.require(:experiment).permit(
        :name,
        :description,
        parts_attributes: [
          :id,
          :name,
          :description,
          :design,
          :_destroy,
          variables_attributes: [
            :id,
            :name,
            :data_type,
            :repetition_count,
            :log_transform,
            :_destroy
          ]
        ]
      )
    end
end

