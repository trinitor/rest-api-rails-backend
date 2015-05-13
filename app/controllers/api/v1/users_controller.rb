class Api::V1::UsersController < Api::V1::ApiV1Controller

  before_action :authenticate, :except => [:create, :login]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # Description  Login with username and password  
  # URL          GET /api/v1/users/login  
  # Header       none  
  # Body         { user : { name, password } }  
  # Return       { user : [{ id, name, auth_token, href }] }  
  def login
    user = User.find_by_name(params[:user][:name])
    if user and user.authenticate(params[:user][:password])
      payload = {
        user: [{
          id: user.id,
          name: user.name,
          auth_token: user.auth_token,
          href: api_v1_user_url(user)
        }],
        message: "successful login"
      }
      render json: payload, status: :ok
    else
      unauthenticated
    end
  end

  # Description  show user profile  
  # URL          GET /api/v1/users/{id}  
  # Header       Authentication  
  # Body         none  
  # Return       { user : [{ name, token }] }  
  def show
    user = User.find(params[:id])

    if @currentuser.id == user.id
      payload = {
        user: [{
          name: user.name,
          token: user.auth_token,
        }],
        message: "view user"
      }
      render json: payload, status: :ok
    else
      unauthenticated
    end
  end

  # Description  create new user account  
  # URL          POST /api/v1/users  
  # Header       none  
  # Body         { user : { name, password, password_confirmation } }  
  # Return       { user: [{ id, name, token, href }] }  
  def create
    user = User.new(user_params)

    if user.save
      if user.email.present?
        DefaultMailer.user_email_welcome(user).deliver_now
      end
      payload = {
        user: [{
          id: user.id,
          name: user.name,
          auth_token: user.auth_token,
          href: api_v1_user_url(user)
        }],
        message: "user created"
      }
      render json: payload, status: :ok
    else
      unauthenticated
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def unauthenticated
      payload = {
        message: "not authorized"
      }
      render json: payload, status: :unauthorized
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
