require 'test_helper'

class Api::V1::UsersControllerTest < ActionController::TestCase
  setup do
    @user01 = users(:user01)
    @user02 = users(:user02)
  end

  #test "api_v1 should get index" do
  #  get :index
  #  assert_response :success
  #  assert_not_nil assigns(:users)
  #end

  test "api_v1 should create user" do
    assert_difference('User.count') do
      post :create, user: { name: "user10", password: "123456", password_confirmation: "123456" }, format: :json
    end
  end

  test "api_v1 should login" do
    get :login, user: { name: @user01.name, password: "123456"}, format: :json
    response = JSON.parse(@response.body)
    assert_equal @user01.auth_token, response['user'][0]['auth_token']
  end

  test "api_v1 should not login with wrong username" do
    get :login, user: { name: "abc", password: "12345X"}, format: :json
    response = JSON.parse(@response.body)
    assert_equal "not authorized", response['message']
  end

  test "api_v1 should not login with wrong password" do
    get :login, user: { name: @user01.name, password: "12345X"}, format: :json
    response = JSON.parse(@response.body)
    assert_equal "not authorized", response['message']
  end

  test "api_v1 should show user" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
    get :show, id: @user01.id, format: :json
    response = JSON.parse(@response.body)
    assert_equal @user01.name, response['user'][0]['name']
  end

  test "api_v1 should not grant access to other users" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
    get :show, id: @user02.id, format: :json
    response = JSON.parse(@response.body)
    assert_equal "not authorized", response['message']
  end

  test "api_v1 should not grant access with empty token" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token=""'
    get :show, id: @user02.id, format: :json
    response = JSON.parse(@response.body)
    assert_equal "not authorized", response['message']
  end

  test "api_v1 should not grant access with non existent token" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="invalid"'
    get :show, id: @user02.id, format: :json
    response = JSON.parse(@response.body)
    assert_equal "not authorized", response['message']
  end

  test "api_v1 should not grant access to unauthorized users" do
    get :show, id: @user02.id, format: :json
    response = JSON.parse(@response.body)
    assert_equal "not authorized", response['message']
  end

  test "api_v1 should not create user with empty name" do
    assert_no_difference('User.count') do
      post :create, user: { name: "", password: "123456", password_confirmation: "123456" }, format: :json
    end
  end

  test "api_v1 should not create user with no password" do
    assert_no_difference('User.count') do
      post :create, user: { name: "user12", password: "", password_confirmation: "" }, format: :json
    end
  end

  test "api_v1 should not create user with non matching passwords" do
    assert_no_difference('User.count') do
      post :create, user: { name: "user13", password: "123456", password_confirmation: "12345X" }, format: :json
    end
  end

  test "api_v1 should not create user with short password" do
    assert_no_difference('User.count') do
      post :create, user: { name: "user13", password: "12345", password_confirmation: "12345" }, format: :json
    end
  end

  test "api_v1 should not create user with long password" do
    assert_no_difference('User.count') do
      post :create, user: { name: "user13", password: "1234567890123456789012345678901", password_confirmation: "1234567890123456789012345678901" }, format: :json
    end
  end

  test "api_v1 should not create user with short name" do
    assert_no_difference('User.count') do
      post :create, user: { name: "ab", password: "123456", password_confirmation: "123456" }, format: :json
    end
  end

  test "api_v1 should not create user with long name" do
    assert_no_difference('User.count') do
      post :create, user: { name: "user12345678901234567", password: "123456", password_confirmation: "123456" }, format: :json
    end
  end
end
