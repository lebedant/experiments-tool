class TestVariablesController < ApplicationController
  before_action :set_test_variable, only: [:show, :edit, :update, :destroy]

  # GET /test_variables
  # GET /test_variables.json
  def index
    @test_variables = Test::Variable.all
  end

  # GET /test_variables/1
  # GET /test_variables/1.json
  def show
  end

  # GET /test_variables/new
  def new
    @test_variable = Test::Variable.new
  end

  # GET /test_variables/1/edit
  def edit
  end

  # POST /test_variables
  # POST /test_variables.json
  def create
    @test_variable = Test::Variable.new(test_variable_params)

    respond_to do |format|
      if @test_variable.save
        format.html { redirect_to @test_variable, notice: 'Test variable was successfully created.' }
        format.json { render :show, status: :created, location: @test_variable }
      else
        format.html { render :new }
        format.json { render json: @test_variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /test_variables/1
  # PATCH/PUT /test_variables/1.json
  def update
    respond_to do |format|
      if @test_variable.update(test_variable_params)
        format.html { redirect_to @test_variable, notice: 'Test variable was successfully updated.' }
        format.json { render :show, status: :ok, location: @test_variable }
      else
        format.html { render :edit }
        format.json { render json: @test_variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /test_variables/1
  # DELETE /test_variables/1.json
  def destroy
    @test_variable.destroy
    respond_to do |format|
      format.html { redirect_to test_variables_url, notice: 'Test variable was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test_variable
      @test_variable = Test::Variable.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def test_variable_params
      params.require(:test_variable).permit(:type, :name, :visualization_method, :space, :log_transform)
    end
end
