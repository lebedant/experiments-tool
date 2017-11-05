require 'test_helper'

class TestPartsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_part = test_parts(:one)
  end

  test "should get index" do
    get test_parts_url
    assert_response :success
  end

  test "should get new" do
    get new_test_part_url
    assert_response :success
  end

  test "should create test_part" do
    assert_difference('TestPart.count') do
      post test_parts_url, params: { test_part: { description: @test_part.description, design_type: @test_part.design_type, name: @test_part.name } }
    end

    assert_redirected_to test_part_url(TestPart.last)
  end

  test "should show test_part" do
    get test_part_url(@test_part)
    assert_response :success
  end

  test "should get edit" do
    get edit_test_part_url(@test_part)
    assert_response :success
  end

  test "should update test_part" do
    patch test_part_url(@test_part), params: { test_part: { description: @test_part.description, design_type: @test_part.design_type, name: @test_part.name } }
    assert_redirected_to test_part_url(@test_part)
  end

  test "should destroy test_part" do
    assert_difference('TestPart.count', -1) do
      delete test_part_url(@test_part)
    end

    assert_redirected_to test_parts_url
  end
end
