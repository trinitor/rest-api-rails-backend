require 'test_helper'

class Api::V1::FriendrequestsControllerTest < ActionController::TestCase
  setup do
    @user01 = users(:user01)
    @user02 = users(:user02)
    @user03 = users(:user03)
    @user04 = users(:user04)
  end

  test "api_v1 should create friend request" do
    assert_difference('Friendrequest.count', 1) do
      @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
      post :create, :user_id=> @user01.id, id: @user04.name, format: :json
    end
  end

  test "api_v1 should not create friendrequest for other user" do
    assert_no_difference('Friendrequest.count') do
      @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
      post :create, :user_id=> @user02.id, id: @user04.name, format: :json
    end
  end

  test "api_v1 should not create empty friend request" do
    assert_no_difference('Friendrequest.count') do
      @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
      post :create, :user_id=> @user01.id, id: "", format: :json
    end
  end


  test "api_v1 should create friend response" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
    patch :update, :user_id=> @user01.id, id: @user03.name, friendrequest: { action: "2" }, format: :json
    response = JSON.parse(@response.body)
    assert_equal 2, response['friendships'][0]['status']
  end

  test "api_v1 should not update friend response for other user" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user03.auth_token+'"'
    patch :update, :user_id=> @user01.id, id: @user02.name, friendrequest: { action: "2" }, format: :json
    response = JSON.parse(@response.body)
    assert_equal "not authorized", response['message']
  end

  test "api_v1 should not create friendship without friendrequest" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user04.auth_token+'"'
    patch :update, :user_id=> @user04.id, id: @user01.name, friendrequest: { action: "2" }, format: :json
    response = JSON.parse(@response.body)
    assert_equal 401, response['status']
  end

  test "api_v1 should not update friend response with status = 4" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user03.auth_token+'"'
    patch :update, :user_id=> @user03.id, id: @user01.name, friendrequest: { action: "5" }, format: :json
    response = JSON.parse(@response.body)
    assert_equal 401, response['status']
  end

  test "api_v1 should show pending requests" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user03.auth_token+'"'
    get :index, user_id: @user03.id, format: :json, status: "pending"
    response = JSON.parse(@response.body)
    assert_equal 1, response['friendrequests'].count
    assert_equal @user01.name, response['friendrequests'][0]['friend_name']
    assert_equal 1, response['friendrequests'][0]['status']
  end

  test "api_v1 should show open requests" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
    get :index, user_id: @user01.id, format: :json, status: "open_requests"
    response = JSON.parse(@response.body)
    assert_equal 3, response['friendrequests'].count
    assert_equal @user04.name, response['friendrequests'][0]['friend_name']
    assert_equal 1, response['friendrequests'][0]['status']
  end
end
