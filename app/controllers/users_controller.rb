class UsersController < ApplicationController
  allow_oauth!
  before_action :authenticate_user, except: [:sign_up, :create]
  skip_before_filter :verify_authenticity_token, only: [:sign_up, :create]
  
  def sign_up
    password = params[:password]
    email = params[:email]
    password_confirmation = params[:password_confirmation]
    
    preexisting_user = User.where({ email: email })
    if preexisting_user.any?
      return render_response false, 'a user with this email already exists'
    end
    
    @user = User.new(email: email, password: password, password_confirmation: password_confirmation)
    if @user.save
      return render_response(true, 'User created succesfully')
    else
      return render_response(false, 'There has been an error')
    end
  end
  
  private

  def render_response success, message
    output = {
      success: success,
      message: message
    }
    return render json: output.as_json
  end

end