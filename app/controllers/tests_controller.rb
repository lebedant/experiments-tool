class TestsController < ApplicationController
  before_action :set_test, only: [:show, :edit, :update, :destroy]
  add_breadcrumb "All Tests", :tests_path

  # GET /tests
  # GET /tests.json
  def index
    @tests = Test.all
  end

  # GET /tests/1
  # GET /tests/1.json
  def show
    add_breadcrumb @test.name, @test
  end

  # GET /tests/new
  def new
    @test = Test.new(user: current_user)
    add_breadcrumb 'New test', new_test_path
  end

  # GET /tests/1/edit
  def edit
    add_breadcrumb "Edit #{@test.name}", edit_test_path(@test)
  end

  # POST /tests
  # POST /tests.json
  def create
    @test = Test.new(test_params)
    @test.user = current_user

    respond_to do |format|
      if @test.save
        format.html {
          flash[:notice] = 'Test was successfully created.'
          redirect_to action: :index
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test
      @test = Test.find(params[:id])
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
          :design_type,
          :_destroy,
          variables_attributes: [
            :id,
            :name,
            :data_type,
            :log_transform,
            :_destroy
          ]
        ]
      )
    end
end
