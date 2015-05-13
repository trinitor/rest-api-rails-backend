class Api::V1::DevicesController < Api::V1::ApiV1Controller
  before_action :authenticate

  before_action :set_device, only: [:show, :update, :destroy]
  before_action :get_user

  def get_user
    @user = User.find(params[:user_id])
  end

  # Description  show all available devices for a spesific user  
  # URL          GET /api/v1/user/{user_id}/devices  
  # Header       Authentication  
  # Body         none  
  # Return       { devices: [{ id, OS, push_token, href }] }  
  def index
    if (@currentuser.id == @user.id)
      devices = @user.devices.all
      devices_output = [ ]
      devices.each do |device|
        devices_output << { id: device.id, OS: device.os, push_token: device.push_token, href: api_v1_user_device_url(@user, device) }
      end
      payload = {
        devices: devices_output,
        message: "show all devices for one user"
      }
      render json: payload, status: :ok
    else
      payload = {
        error: "not authorized to view rows for this game",
        status: 401
      }
      render json: payload, status: :unauthorized
    end
  end

  # Description  show details for one device  
  # URL          GET /api/v1/users/{user_id}/devices/{device_id}  
  # Header       Authentication  
  # Body         none  
  # Return       { devices: [{ id, OS, push_token, href }] }  
  def show
    if (@currentuser.id == @user.id)
      if Device.find(params[:id]).user_id == @user.id
        device = @user.devices.find(params[:id])
        payload = { 
          devices: [ { id: device.id, OS: device.os, push_token: device.push_token, href: api_v1_user_url(@user) }],
           message: "show device"
        }
        render json: payload, status: :ok
      else
        payload = {
          error: "not authorized",
          status: 401
        }
        render json: payload, status: :unauthorized
      end
    else
      payload = {
        error: "not authorized",
        status: 401
      }
      render json: payload, status: :unauthorized
    end
  end

  # Description  create new device for user  
  # URL          POST /api/v1/users/{user_id}/devices  
  # Header       Authentication  
  # Body         { device : { user_id, os, push_token}}  
  # Return       { device : [{ id, OS, push_token, href }] }  
  def create
    @device = Device.new(device_params)
    if (@user.id == @device.user_id) and (@currentuser.id == @user.id)
      if @device.save
        payload = {
          device: [{
            id: @device.id,
            OS: @device.os,
            push_token: @device.push_token,
            href: api_v1_user_device_url(@user, @device)
          }],
          message: "device created"
        }
        render json: payload, status: :created
      else
        render json: @device.errors, status: :unprocessable_entity
      end
    else
      payload = {
        error: "not authorized to create device",
        status: 401
      }
      render json: payload, status: :unauthorized
    end
  end

  # Description  update the timestamp of a device device for user  
  # URL          POST /api/v1/users/{user_id}/devices/{device_id}  
  # Header       Authentication  
  # Body         { device : { user_id, os, push_token}}  
  # Return       { device : [{ id, OS, push_token, href }] }  
  def update
    device = Device.where(push_token: params["device"]["push_token"]).first

    if (@currentuser.id == @user.id) and (device.user_id == @user.id)
      if device.update(device_params)
        payload = {
          device: [{
            id: device.id,
            OS: device.os,
            push_token: device.push_token,
            href: api_v1_user_device_url(@user, device)
          }],
          message: "device updated"
        }
        render json: payload, status: :created
      else
        payload = {
          error: device.errors,
          status: "500"
        }
        render json: payload, status: :unprocessable_entity
      end
    else
      payload = {
        error: "not authorized to create device",
        status: 401
      }
      render json: payload, status: :unauthorized
    end
  end

  # Description  register (create or update) device for user  
  # URL          POST /api/v1/users/{user_id}/devices  
  # Header       Authentication  
  # Body         { device : { user_id, os, push_token}}  
  # Return       { device : [{ id, OS, push_token, href }] }  
  def register
    device = Device.where(push_token: params["device"]["push_token"]).first
    if device.nil?
      create
    else
      update
    end
  end

  # Description  delete device for user  
  # URL          DELETE /api/v1/users/{user_id}/devices/{device_id}  
  # Header       Authentication  
  # Body         None  
  # Return       { devices: [{status}] }  
  def destroy
    if (@currentuser.id == @user.id)
      device = Device.find(params[:id])
      if device.user_id == @currentuser.id
        device = @user.devices.find(params[:id])
        device.destroy
          payload = {
            devices: [{
              status: 0
            }],
            message: "device removed"
          }
          render json: payload, status: :created
      else
        payload = {
          error: "not authorized to delete device",
          status: 401
        }
        render json: payload, status: :unauthorized
      end
    else
      payload = {
        error: "not authorized to delete device",
        status: 401
      }
      render json: payload, status: :unauthorized
    end
  end

  private

    def set_device
      @device = Device.find(params[:id])
    end

    def device_params
      params.require(:device).permit(:user_id, :os, :push_token, :status)
    end
end
