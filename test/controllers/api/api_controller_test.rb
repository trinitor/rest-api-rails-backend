require 'test_helper'

class Api::ApiControllerTest < ActionController::TestCase

  test "api is accessible" do
    get :index, format: :json
    response = JSON.parse(@response.body)
    assert_equal "myproject", response['title']
    assert_equal "v1", response['resources'][0]['name']
    assert_equal "/v1", response['resources'][0]['url']
  end
end
