class Api::V1::FriendsController <  Api::V1::ApiV1Controller
  before_action :authenticate

  before_filter :get_user

  def get_user
    @user = User.find(params[:user_id])
  end

  # Description  show all fiends for a spesific game  
  # URL          GET /api/v1/users/{user_id}/friends  
  # Header       Authentication  
  # Body         none  
  # Return:      { friends : [{ user_id, name, status }] }  
  def index
    if (@currentuser.id == @user.id)
      if params[:status] == "pending"
        friendships = Friendrequest.where(user_id: @user.id, status: "1")
        message = "show all pending users for one user"
      elsif params[:status] == "open_requests"
        friendships = Friendrequest.where(friend_id: @user.id, status: "1")
        message = "show all open requests for one user"
      else
        friendships = @user.friendships.where(status: "2")
        message = "show all confirmed friends for one user"
      end
      friends_list = [ ]
      if params[:status] == "open_requests"
        friendships.each do |friendship|
          friends_list << {friend_id: friendship.user.id, friend_name: friendship.user.name, status: friendship.status, href: api_v1_user_url(friendship.user) }
        end
      else
        friendships.each do |friendship|
          friends_list << {friend_id: friendship.friend.id, friend_name: friendship.friend.name, status: friendship.status, href: api_v1_user_url(friendship.friend) }
        end
      end
      payload = {
        friends: friends_list,
        message: message
      }
      render json: payload, status: :ok
    else
      unauthenticated
    end
  end

  # Description  show details for one friend  
  # URL          GET /api/v1/users/{user_id}/friends/{username}  
  # Header       Authentication  
  # Body         none  
  # Return:      { friends : [{ user_id, name, status }] }  
  def show
    if (@currentuser.id == @user.id)
      friend = User.where(name: params[:id]).first
      friendship = @user.friendships.where(friend_id: friend.id).first
      payload = {
        friends: [{
          friend_id: friendship.friend.id,
          friend_name: friendship.friend.name,
          status: friendship.status,
          href: api_v1_user_url(friendship.friend)
        }]
      }
      render json: payload, status: :ok
    end
  end

  # Description  delete friendship  
  # URL          DELETE /api/v1/users/{user_id}/friends/{username}  
  # Header       Authentication  
  def destroy
    friend = User.find_by_name(params[:id])
    if @currentuser.id == @user.id
      #if friendship_request.destroy
      if Friendship.delete_friendship(@user.id, friend.id)
        payload = {
          friendship: [{
            status: 0
          }],
          message: "friendship removed"
        }
        render json: payload, status: :created
      else
        render json: friendship_request.errors, status: :unprocessable_entity
      end
    else
      unauthenticated
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_row
      @row = Row.find(params[:id])
    end

    def unauthenticated
      payload = {
        message: "not authorized"
      }
      render json: payload, status: :unauthorized
    end

    def friendship_params
      params.require(:friendship).permit(:user_id, :friend_id, :status )
    end
end
