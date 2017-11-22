require 'histogram/array'

class TestsController < ApplicationController
  allowed_ghost_actions [:to_test, :to_edit, :to_open, :to_closed]
  before_action :set_test, except: [:new, :create, :index]
  before_action :check_state, only: [:edit, :update]
  add_breadcrumb I18n.t(:test_plural), :tests_path


  def colors
    [
      "rgba(20,220,220,0.3)",
      "rgba(30,240,120,0.3)",
      "rgba(40,120,200,0.3)",
      "rgba(120,220,220,0.3)",
      "rgba(20,220,220,0.3)"
    ]
  end

  # GET /tests
  # GET /tests.json
  def index
    @tests = Test.page(params[:page])
  end

  # GET /tests/1
  # GET /tests/1.json
  def show
    add_breadcrumb "#{@test.name}", @test
    # group by variable
    @grouped_by_variable = @test.data.active.group_by(&:variable)

    # Grouped select options for all variables (grouped by part)
    @grouped_variables = {}
    @test.parts.each do |part|
      @grouped_variables[part.name] = part.variables.pluck(:name, :id)
    end

    @target_vars = @test.variables.not_strings.pluck(:name).uniq
    @filter_vars = @test.variables.strings.pluck(:name).uniq

    # Histogram chart for check data
    prepare_data_for_var(params[:chart_variable]) if params[:chart_variable].present?

    # Boxplot chart
    prepare_boxplot_data(
      params[:target_var_name],
      params[:filter_var_name],
      params[:filter_var_values]
    ) if params[:target_var_name].present? && params[:filter_var_name].present? && !params[:filter_var_values].blank?

    @filter_values = {}

    @filter_vars.each do |variable_name|
      @filter_values[variable_name] = @test.json_data.pluck("data ->> '#{variable_name}'").uniq
      @filter_values[variable_name] << "all"
    end

    #
    respond_to do |format|
      format.html {}
      # Download as json
      format.json {
        file_name = "#{@test.name.parameterize.underscore}"
        flash[:notice] = 'Test was successfully exported.'
        content = @test.to_json
        send_data content, filename: "#{file_name}.json"
      }
    end
  end

  # GET /tests/new
  def new
    @test = Test.new(user: current_user)
    add_breadcrumb t(:new_test_breadcrumb), new_test_path
  end

  # GET /tests/1/edit
  def edit
    add_breadcrumb "#{@test.name}", @test
    add_breadcrumb t(:edit_breadcrumb), edit_test_path(@test)
  end

  # POST /tests
  # POST /tests.json
  def create
    add_breadcrumb t(:new_test_breadcrumb), {}
    @test = Test.new(test_params)
    @test.user = current_user

    respond_to do |format|
      if @test.save
        format.html {
          flash[:notice] = 'Test was successfully created.'
          redirect_to @test
        }
        format.json { render :show, status: :created, location: @test }
      else
        format.html { render :new }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tests/1
  # PATCH/PUT /tests/1.json
  def update
    respond_to do |format|
      if @test.update(test_params)
        format.html {
          flash[:notice] = 'Test was successfully updated.'
          redirect_to @test
        }
        format.json { render :show, status: :ok, location: @test }
      else
        format.html { render :edit }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tests/1
  # DELETE /tests/1.json
  def destroy
    @test.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = 'Test was successfully destroyed.'
        redirect_to tests_url
      }
      format.json { head :no_content }
    end
  end

  # POST /tests/1/copy
  # POST /tests/1/copy.json
  def copy
    new_test = @test.amoeba_dup

    respond_to do |format|
      if new_test.save
        format.html {
          flash[:notice] = 'Test was successfully duplicated.'
          redirect_to new_test
        }
        format.json { render :show, status: :ok, location: new_test }
      else
        format.html {
          flash[:notice] = new_test.errors.full_messages.join(', ')
          redirect_to @test
        }
        format.json { render json: new_test.errors, status: :unprocessable_entity }
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
    if @test.send transition
      flash[:notice] = 'Test state was successfully changed.'
    else
      flash[:alert] = 'Invalid test state transition.'
    end
    redirect_to @test
  end

  #
  # As the action will call the method, it's necessary to handle the behavior if this method doesn't exist.
  #
  def method_missing(name, *args, &block)
    return change_state(name) if respond_to?(name, true)
    super
  end

  def to_test
    if @test.to_test
      flash[:notice] = 'Test state was successfully changed.'
    else
      flash[:alert] = 'Invalid test state transition.'
    end
    redirect_to @test
  end

  private

    def prepare_data_for_var(variable_id)
      variable = Test::Variable.find(variable_id)
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
      target_var = Test::Variable.where(name: target_var_name).first
      filter_var = Test::Variable.where(name: filter_var_name).first

      x_labels = filter_var_values.reject(&:blank?).map { |value| "#{filter_var.name} #{value}" }

      return if x_labels.empty?

      # labels from filter_variable
      @boxplot_data = { labels: x_labels, datasets: [] }
      # for color
      i = 0

      @test.parts.each do |part|
        means,uppers,lowers = calculate_means_for(part, target_var, filter_var, filter_var_values)

        @boxplot_data[:datasets] << {
                            label: part.name, # legend name => part name
                            backgroundColor: colors[i],
                            data:  means,
                            error: means.map{|m|  m / 10}
                          }
        i += 1
      end
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
      if !@test.edit?
        flash[:alert] = 'Editation is closed.'
        redirect_to @test
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_test
      @test = Test.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def test_params
      params.require(:test).permit(
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
            :type,
            :repetition_count,
            :log_transform,
            :_destroy
          ]
        ]
      )
    end
end

