require 'test_helper'

class Api::V1::DevicesControllerTest < ActionController::TestCase
  setup do
    @user01 = users(:user01)
    @user02 = users(:user02)
    @u1_d1 = devices(:u1_d1)
    @u2_d1 = devices(:u2_d1)
  end

  test "api_v1 should show devices" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
    get :index, user_id: @user01.id
    response = JSON.parse(@response.body)
    assert_equal 3, response['devices'].count
  end

  test "api_v1 should not show devices for other users" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
    get :index, user_id: @user02.id
    response = JSON.parse(@response.body)
    assert_equal 401, response['status']
  end


  test "api_v1 should show device" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
    get :show, user_id: @user01.id, id: @u1_d1.id
    response = JSON.parse(@response.body)
    assert_equal 1, response['devices'].count
  end

  test "api_v1 should not show device for other user" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
    get :show, user_id: @user02.id, id: @u2_d1.id
    response = JSON.parse(@response.body)
    assert_equal 401, response['status']
  end

  test "api_v1 should not show device that belongs to another user" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
    get :show, user_id: @user01.id, id: @u2_d1.id
    response = JSON.parse(@response.body)
    assert_equal 401, response['status']
  end


  test "api_v1 should create device" do
    assert_difference('Device.count') do
      @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
      post :create, user_id: @user01.id, device: { user_id: "21637642", os: "iOS", push_token: "abc4"}
    end
  end

  test "api_v1 should not create device for other user" do
    assert_no_difference('Device.count') do
      @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
      post :create, user_id: @user02.id, device: { user_id: @user02.id, os: "iOS", push_token: "abc5"}
    end
  end

  test "api_v1 should not create device with existing push token" do
    assert_no_difference('Device.count') do
      @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
      post :create, user_id: @user01.id, device: { user_id: @u1_d1.push_token, os: "iOS", push_token: @u2_d1.push_token}
    end
  end


  test "api_v1 should not update device for other user url" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
    patch :update, :user_id=> @user02.id, id: @u2_d1.id, device: { user_id: @user02.id, os: "iOS", push_token: "abc6foo"}
    response = JSON.parse(@response.body)
    assert_equal 401, response['status']
  end

  test "api_v1 should not update device that belongs to another user" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
    patch :update, :user_id=> @user01.id, id: @u2_d1.id, device: { user_id: @user01.id, os: "iOS", push_token: @u2_d1.push_token}
    response = JSON.parse(@response.body)
    assert_equal 401, response['status']
  end

  test "api_v1 should not update device and force it to belong to another user" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
    patch :update, :user_id=> @user02.id, id: @u2_d1.id, device: { user_id: @user01.id, os: "iOS", push_token: "abc6foo"}
    response = JSON.parse(@response.body)
    assert_equal 401, response['status']
  end


  test "api_v1 should register new device and create new device" do
    assert_difference('Device.count', 1) do
      @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
      post :register, :user_id=> @user01.id, id: @u1_d1.id, device: { user_id: @user01.id, os: "iOS", push_token: "abc4"}
      response = JSON.parse(@response.body)
      assert_equal "abc4", response['device'][0]['push_token']
    end
  end

  test "api_v1 should register existing device and update device" do
    assert_no_difference('Device.count') do
      @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
      post :register, :user_id=> @user01.id, id: @u1_d1.id, device: { user_id: @user01.id, os: "iOS", push_token: @u1_d1.push_token}
      response = JSON.parse(@response.body)
      assert_equal @u1_d1.push_token, response['device'][0]['push_token']
    end
  end

  test "api_v1 should not register device with existing push_token" do
    assert_no_difference('Device.count') do
      @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
      post :register, :user_id=> @user01.id, id: @u1_d1.id, device: { user_id: @user01.id, os: "iOS", push_token: @u2_d1.push_token}
      response = JSON.parse(@response.body)
      assert_equal 401, response['status']
    end
  end


  test "api_v1 should delete device" do
    assert_difference('Device.count', -1) do
      @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
      delete :destroy, user_id: @user01.id, id: @u1_d1.id, format: :json
    end
  end

  test "api_v1 should not delete device while using another user_id" do
    assert_no_difference('Device.count') do
      @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
      delete :destroy, user_id: @user02.id, id: @u2_d1.id, format: :json
    end
  end

  test "api_v1 should not delete device which belongs to another user" do
    assert_no_difference('Device.count') do
      @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
      delete :destroy, user_id: @user01.id, id: @u2_d1.id, format: :json
    end
  end
end
