require 'test_helper'

class Api::V1::FriendsControllerTest < ActionController::TestCase
  setup do
    @user01 = users(:user01)
    @user02 = users(:user02)
    @user03 = users(:user03)
    @user04 = users(:user04)
  end

  test "api_v1 should show friends" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
    get :index, user_id: @user01.id, format: :json
    response = JSON.parse(@response.body)
    assert_equal 3, response['friends'].count
  end

  test "api_v1 should not show friends from other user" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
    get :index, user_id: @user02.id, format: :json
    response = JSON.parse(@response.body)
    assert_equal "not authorized", response['message']
  end

  test "api_v1 should show active friend" do
    @request.env['HTTP_AUTHORIZATION'] = 'Token token="'+@user01.auth_token+'"'
    get :show, user_id: @user01.id, id: @user02.name, format: :json
    response = JSON.parse(@response.body)
    assert_equal 1, response['friends'].count
    assert_equal @user02.name, response['friends'][0]['friend_name']
    assert_equal 2, response['friends'][0]['status']
  end
end
