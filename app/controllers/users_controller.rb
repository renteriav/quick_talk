class UsersController < ApplicationController
  allow_oauth!
  before_action :authenticate_user, except: [:sign_up, :create]
  skip_before_filter :verify_authenticity_token, only: [:sign_up, :create]
  
  def sign_up
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    email = params[:email]
    share_code = params[:share_code]   
    
    #check for pre-existing user
    preexisting_user = User.where({ email: email })
    if preexisting_user.any?
      return render_response false, 'a user with this email already exists'
    end
    
    #check share code
    if !share_code.nil? && share_code != ""
      share = Share.find_by share_code: share_code
      if share
        inviter = User.find(share.user_id)
        accountant = inviter.get_accountant
        share.accepted_at = Time.now
        phone = share.phone
      else
        return render_response(false, 'Invalid Share Code')
      end
    else
      phone = nil
      accountant = User.first
    end

    @user = User.new(email: email, password: password, password_confirmation: password_confirmation, phone: phone)
    if @user.save
      @relationship = Relationship.new(user_id: accountant.id, client_id: @user.id)
      if @relationship.save
        if share
          share.invitee_id = @user.id
          share.accepted_at = Time.now
          if share.save
            return render_response(true, 'User created succesfully')
          else
            return render_response(false, 'User was created but share code could not be processed')
          end
        else
          return render_response(true, 'User created succesfully')
        end
      else
        return render_response(false, 'User was created but no sponsor was assigned')
      end
    else
      return render_response(false, 'User could not be created')
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