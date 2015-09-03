class SharesController < ApplicationController
  include ShareCreator
  include Namer
  layout 'layouts/empty'
  def new
    if params[:token]
      @accountant = User.find_by share_token: params[:token]
      if @accountant
        @share = Share.new
      else
        redirect_to root_path
        authenticate_user!
      end
    else
      redirect_to root_path
      authenticate_user!
    end
  end
  
  def create
    accountant = User.find(params[:user_id])
    accountant_name = name_or_email accountant
    @share = accountant.shares.build(share_params)
    respond_to do |format|
      if @share.save
        phone = @share.phone
        message_body = share_message_body(accountant_name, @share.share_code, accountant_name)
        if invitation = send_sms(phone, message_body)
          Rails.logger.info "==============> Share SMS Sent Succesfully"
        else
          Rails.logger.info "==============> Share SMS failed: #{invitation.inspect}"
        end
        format.js {render action: "share_code"}
      else
        format.html { render action: "new" }
      end
    end
  end
  
  private
  
  def share_params
    params.require(:share).permit(:user_id, :phone, :share_code)
  end
end