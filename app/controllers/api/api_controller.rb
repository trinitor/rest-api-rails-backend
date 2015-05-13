class Api::ApiController < ActionController::API

  # allow token auth header when using the rails-api gem
  include ActionController::HttpAuthentication::Token::ControllerMethods

  def index
    payload = {
      name:        "api server",
      title:       "myproject",
      description: "json api for myproject",
      protocol:    "rest",
      rootUrl:     "http://api.example.com/.",
      servicePath: "/api/.",
      resources: [
        { name: "v1", url: "/v1" }
      ]
    }
    render json: payload, status: :ok
  end
end
