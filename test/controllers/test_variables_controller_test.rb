require 'test_helper'

class TestVariablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_variable = test_variables(:one)
  end

  test "should get index" do
    get test_variables_url
    assert_response :success
  end

  test "should get new" do
    get new_test_variable_url
    assert_response :success
  end

  test "should create test_variable" do
    assert_difference('TestVariable.count') do
      post test_variables_url, params: { test_variable: { log_transform: @test_variable.log_transform, name: @test_variable.name, space: @test_variable.space, type: @test_variable.type, visualization_method: @test_variable.visualization_method } }
    end

    assert_redirected_to test_variable_url(TestVariable.last)
  end

  test "should show test_variable" do
    get test_variable_url(@test_variable)
    assert_response :success
  end

  test "should get edit" do
    get edit_test_variable_url(@test_variable)
    assert_response :success
  end

  test "should update test_variable" do
    patch test_variable_url(@test_variable), params: { test_variable: { log_transform: @test_variable.log_transform, name: @test_variable.name, space: @test_variable.space, type: @test_variable.type, visualization_method: @test_variable.visualization_method } }
    assert_redirected_to test_variable_url(@test_variable)
  end

  test "should destroy test_variable" do
    assert_difference('TestVariable.count', -1) do
      delete test_variable_url(@test_variable)
    end

    assert_redirected_to test_variables_url
  end
end
