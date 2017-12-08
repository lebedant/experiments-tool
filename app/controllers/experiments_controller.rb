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

    @string_var_ids = @experiment.variables.strings.pluck(:id)

    # Histogram chart for check data
    prepare_data_for_var(params[:chart_variable]) if params[:chart_variable].present?

    # Boxplots hash
    @boxplots = {}

    @experiment.chart_queries.each do |query|
      @max = 0
      plot_data,raw_data,header_row = prepare_boxplot_data(query)

      # Boxplot chart
      @boxplots[query.name] = {
        id: query.id,
        name_code: query.name.parameterize,
        data: plot_data,
        max: (@max + 50).round,
        raw_data: raw_data,
        header_row: header_row
      }
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
      @definition = ChartQuery.new(experiment_id: @experiment.id)
      @target_vars = @experiment.variables.not_strings.pluck(:name).uniq
      @filter_vars = @experiment.variables.strings.pluck(:name).uniq
      @calculate_methods = Experiment::Variable::METHODS.map{ |key, value| [t(key), value] }

      @filter_values = {}

      @filter_vars.each do |variable_name|
        @filter_values[variable_name] = @experiment.json_data
                                                   .pluck("data ->> '#{variable_name}'")
                                                   .compact
                                                   .uniq
        @filter_values[variable_name] << "all"
      end
    end

    def prepare_data_for_var(variable_id)
      variable = Experiment::Variable.find(variable_id)
      # can't work without data
      if variable.data.blank?
        return
      end
      if variable.string?
        @raw_data = variable.data
        pairs = @raw_data.group_by(&:itself).map { |k,v| [k, v.count] }.to_h
      else
        @raw_data = variable.long? ? variable.data.map(&:to_i) : variable.data.map(&:to_f)
        settings = {}
        settings[:bin_width] = params[:step_size].to_i if params[:step_size].present?
        settings[:min] = params[:min].to_i if params[:min].present?
        settings[:max] = params[:max].to_i if params[:max].present?
        bar_count = params[:bar_count].to_i if params[:bar_count].present?
        begin
          x,y = @raw_data.histogram(bar_count, settings)
          x.map!{|item| item.round(3)}
          pairs = x.zip(y)
        rescue
          # handle error
          flash[:error] = 'Something was wrong...try again'
          return redirect_to @experiment
        end
      end
      # histogram plot
      @histogram_data = [variable.name]
      @histogram_data << pairs.map { |value, count| { x: value, y: count } }
    end

    def prepare_boxplot_data(query)
      target_var = Experiment::Variable.where(name: query.target_variable).first
      filter_var = Experiment::Variable.where(name: query.filter_variable).first

      x_labels = query.filter_variable_values.reject(&:blank?)
                                               .map { |value| "#{filter_var.name} #{value}" }

      return if x_labels.empty?

      raw_data = []

      # labels from filter_variable
      boxplot_data = { labels: x_labels, datasets: [] }
      # for color
      i = 0

      @experiment.parts.each do |part|
        next unless part.variables.pluck(:name).include? target_var.name

        means,uppers,lowers = calculate_means_for(
                                                   part,
                                                   target_var,
                                                   filter_var,
                                                   query.filter_variable_values,
                                                   query.calculate_method
                                                 )
        @max = uppers.max if @max < uppers.max

        boxplot_data[:datasets] << {
                            label: part.name, # legend name => part name
                            backgroundColor: colors[i],
                            errorColor: 'rgba(128,128,128,0.8)',
                            errorStrokeWidth: 1,
                            errorCapWidth: 0.5,
                            data:  means,
                            uppers: uppers,
                            lowers: lowers
                          }
        i += 1

        tmp_ar = []
        means.size.times do |ind|
          tmp_ar << "#{means[ind]}(#{lowers[ind]}, #{uppers[ind]})"
        end

        raw_data << [part.name, tmp_ar].flatten
      end

      [boxplot_data, raw_data, x_labels]
    end

    def calculate_means_for(part, target_var, filter_var, filter_var_values, calculate_method)
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

        calculator = CiCalculator.new(data_array, target_var, calculate_method)
        # calculate
        mean,upper,lower = calculator.mean_and_error

        # push to result arrays
        means  << mean
        uppers << upper
        lowers << lower
      end
      # return multiple values
      [means, uppers, lowers]
    end

    # ----------------------------------------

    def check_state
      if !@experiment.edit?
        flash[:alert] = 'Editation is closed.'
        redirect_to experiments_path
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
            :calculation_method,
            :positive_value,
            :_destroy
          ]
        ]
      )
    end
end

