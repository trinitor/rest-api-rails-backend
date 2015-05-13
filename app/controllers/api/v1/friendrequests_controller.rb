class Api::V1::FriendrequestsController <  Api::V1::ApiV1Controller
  before_action :authenticate

  before_filter :get_user

  def get_user
    @user = User.find(params[:user_id])
  end

  # Description  show all fiendrequests for a spesific user  
  # URL          GET /api/v1/users/{user_id}/friendrequests  
  # Header       Authentication  
  # Body         none  
  # Return:      { friendrequests : [{ user_id, name, status }] }  
  def index
    if (@currentuser.id == @user.id)
      if params[:status] == "pending"
        requests = Friendrequest.where(user_id: @user.id, status: "1")
        message = "show all pending users for one user"
      elsif params[:status] == "open_requests"
        requests = Friendrequest.where(friend_id: @user.id, status: "1")
        message = "show all open requests for one user"
      else
        requests = Friendrequest.where('user_id=? OR friend_id=?', @currentuser.id, @currentuser.id)
        message = "show all friendrequests for one user"
      end
      # in case of the filter for open requests the user_id and friend_id values will be switched. Makes the output json more understandable
      request_list = [ ]
      if params[:status] == "open_requests"
        requests.each do |request|
          request_list << {friend_id: request.user.id, friend_name: request.user.name, status: request.status, href: api_v1_user_url(request.user) }
        end
      else
        requests.each do |request|
          request_list << {friend_id: request.friend.id, friend_name: request.friend.name, status: request.status, href: api_v1_user_url(request.friend) }
        end
      end
      payload = {
        friendrequests: request_list,
        message: message
      }
      render json: payload, status: :ok
    else
      unauthenticated
    end
  end

  # Description  create a new friend request  
  # URL          PUT /api/v1/users/{user_id}/friendrequests/{username}  
  # Header       Authentication  
  # Body         none  
  # Retun:       { friendrequests : [{ user, friend, status, href }] }  
  def create
    if params[:id].present?
      friend = User.find_by_name(params[:id])
      if friend.present?
        if @currentuser.id == @user.id
          params = {
            friendrequest: {
              user_id: @user.id,
              friend_id: friend.id,
              status: 1
            }
          }
          request = Friendrequest.new(user_id: @user.id, friend_id: friend.id, status: 1)
          if request.save
            payload = {
              friendrequests: [{
                user: request.user.name,
                friend: request.friend.name,
                status: request.status,
                href: api_v1_user_friendrequest_url(@user, request)
              }],
              message: "request created"
            }
            render json: payload, status: :created
          else
            render json: friendship_request.errors, status: :unprocessable_entity
          end
        else
          unauthenticated
        end
      else
        payload = {
          error: "error in request",
          status: 400
        }
        render json: payload, status: :bad_request
      end
    else
        payload = {
          error: "ID is required",
          status: 400
        }
        render json: payload, status: :bad_request
    end

  end

  # Description  create a new friend response  
  # URL          PATCH /api/v1/users/{user_id}/friendrequests/{username}  
  # Header       Authentication  
  # Body         { friendrequest : { action }}  
  # Retun:       { friendrequests : [{ user, friend, status, href }] }  
  def update
    if params[:id]
      friend = User.find_by_name(params[:id])
      if @currentuser.id == @user.id
        if params[:friendrequest][:action] == "2"
          action = 2
        elsif params[:friendrequest][:action] == "3"
          action = 3
        end
        friendrequest = Friendrequest.where("user_id = ? AND friend_id = ?", friend.id, @user.id).first
        if friendrequest
          if action.present?
            if Friendship.create_friendship(@user.id, friend.id, action)
              friendship = Friendship.where("user_id = ? AND friend_id = ?", @user.id, friend.id).first
              payload = {
                friendships: [{
                  friend: friendship.friend.name,
                  status: friendship.status,
                  href: api_v1_user_friend_url(@user, friendship.friend)
                }],
                message: "response created"
              }
              render json: payload, status: :created
            else
              render json: friendship_request.errors, status: :unprocessable_entity
            end
          else
            render json: {message: "invalid request", status: 400}, status: :unprocessable_entity
          end
        else
          payload = {
            status: 401,
            message: "no friend request found"
          }
          render json: payload, status: :bad_request
        end
      else
        unauthenticated
      end
    end
  end

  # Description  delete friendrequest  
  # URL          DELETE /api/v1/users/{user_id}/friendrequests/{username}  
  # Header       Authentication  
  def destroy
    if params[:id]
      friend = User.find_by_name(params[:id])
      if @currentuser.id == @user.id
        if Friendrequest.find(params[:id]).destroy
          payload = {
            friendship: [{
              status: 0
            }],
            message: "friendrequest removed"
          }
          render json: payload, status: :created
        else
          render json: friendship_request.errors, status: :unprocessable_entity
        end
      else
        unauthenticated
      end
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

    def friendrequest_params
      params.require(:friendrequest).permit(:user_id, :friend_id, :status)
    end
end
