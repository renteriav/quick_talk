module Api
  module V1
    class ShareController < ApplicationController
      include Namer
      include ShareCreator
      skip_before_filter :verify_authenticity_token
      allow_oauth!

      def create
        #validate phone
        phone = params[:phone].strip.gsub(/\D/, '') || ''
        if !phone || phone.empty?
          return render_response false, 'Missing or invalid phone'
        end
        existing_phone = User.find_by phone: phone
        if existing_phone
          return render_response false, 'Whoops, your friend already has an account!'
        end
        
        #validate user
        if current_user
          inviter = current_user
          inviter_name = name_or_email inviter
        else
          return render_response false, 'Unauthorized user'
        end
        
        #get associated accountant
        if inviter.get_accountant
          accountant = inviter.get_accountant
          accountant_name = name_or_email accountant
        else
          return render_response false, 'No accountant found for inviting user'
        end
        
        share = Share.new
        share.phone = phone
        share.user_id = inviter.id
        if share.save
          message_body = share_message_body(accountant_name, share.share_code, accountant_name)
          if invitation = send_sms(phone, message_body)
            Rails.logger.info "==============> Share SMS Sent Succesfully"
          else
            Rails.logger.info "==============> Share SMS failed: #{invitation.inspect}"
          end
          return render_response true, 'Share successfully created'
        else
          return render_response false, 'Share could not be created'
        end
  
      end

      def detect_and_redirect
        if request.user_agent =~ /iPhone|iPad|iPod|iphone|ipad|ipod/i
          return redirect_to 'http://cllp.co/16hHcTJ'
        elsif request.user_agent =~ /Android|android/i
          return redirect_to 'https://play.google.com/store/apps/details?id=coms.apps.autokept'
        else
          return render text: 'please open this link on a mobile device'
        end
      end

      private

      def render_response success, message
        Rails.logger.info "==============> #{message.inspect}"
        output = {
          success: success,
          message: message
        }
        render json: output.as_json
      end

    end
  end
end