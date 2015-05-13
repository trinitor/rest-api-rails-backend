class Api::V1::ApiV1Controller < Api::ApiController

  def index
    payload = {
      name:        "myproject",
      version:     "v1",
      title:       "myproject",
      description: "json api for myproject",
      protocol:    "rest",
      rootUrl:     "http://api.example.com/.",
      servicePath: "/api/v1/.",
      resources: [
      ]
    }
    render json: payload, status: :ok
  end

  private
    def authenticate
      authenticate_token || render_unauthorized
    end

    def authenticate_token
      authenticate_with_http_token do |auth_token, options|
        @currentuser = User.where(auth_token: auth_token).first
      end
    end

    def render_unauthorized
      payload = {
        message: "not authorized"
      }
      render json: payload, status: 401
    end
end
