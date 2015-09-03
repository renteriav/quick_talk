class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout :layout_by_resource
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url
  end
  
  private

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
  helper_method :mobile_device?

  def prepare_for_mobile
    session[:mobile_param] = params[:mobile] if params[:mobile]
    request.format = :mobile if mobile_device?
  end
  
  def generate_token
    SecureRandom.urlsafe_base64(16)
  end
  
  protected

  def layout_by_resource
    if devise_controller? && resource_name == :user && action_name == "new"
      "empty"
    else
      "application"
    end
  end
  
  def send_sms(dest_phone, sms_body)
    require 'twilio-ruby'
    
    account_sid = 'ACb5bfeb67ceedd54abb7594eb7842955f'
    auth_token = 'f01d5c5b83934c17e1feadc27639cbc7'

    origin_phone = '+15202212153'
    destination_phone = dest_phone

    if destination_phone.size == 10
      destination_phone = "+1#{destination_phone}"
    end

    # set up a client to talk to the Twilio REST API 
    @client = Twilio::REST::Client.new account_sid, auth_token 
     
    @client.messages.create({
      from: origin_phone,
      to: destination_phone,
      body: sms_body
    })
    return true
  rescue
    return false
  end
  
end
