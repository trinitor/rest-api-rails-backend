require 'test_helper'

class Api::V1::ApiV1ControllerTest < ActionController::TestCase
  test "api is accessible" do
    get :index, format: :json
    response = JSON.parse(@response.body)
    assert_equal "myproject", response['title']
    assert_equal "/api/v1/.", response['servicePath']
  end
end
