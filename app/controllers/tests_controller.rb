class TestsController < ApplicationController
  allowed_ghost_actions [:to_test, :to_edit, :to_open, :to_closed]
  before_action :set_test, except: [:new, :create, :index]
  before_action :check_state, only: [:edit, :update]
  add_breadcrumb I18n.t(:test_plural), :tests_path

  # GET /tests
  # GET /tests.json
  def index
    @tests = Test.page(params[:page])
  end

  # GET /tests/1
  # GET /tests/1.json
  def show
    add_breadcrumb "#{@test.name} [#{@test.state}]", @test
    # group by variable
    @grouped_by_variable = @test.data.active.group_by(&:variable)
    # select all but StringDatum
    filtered_data_for_plots = @grouped_by_variable.select { |variable, values| variable.type != :string }

    @plot_data = {}
    # prepare plot data
    filtered_data_for_plots.each do |var, data|
      unsorted_data = data.map { |datum| { name: "D##{datum.id}", value: datum.target.value } }
      @plot_data["#{var.part} #{var.name}"] = unsorted_data.sort_by {|item| item[:value]}
    end

    # byebug

    # @plot_data = [{name: 'A', value: 3}, {name: 'B', value: 8}, {name: 'C', value: 1}]
    # @plot_data = @grouped_data.select{ |data, val| data.name == "Vek" }.values.first
    # @plot_data = @plot_data.map { |datum| { name: "P##{datum.participant_id}", value: datum.target.value } }

    respond_to do |format|
      format.html {}
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
          redirect_to action: :show
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

