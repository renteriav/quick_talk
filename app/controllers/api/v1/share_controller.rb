module Api
  module V1
    class ShareController < ApplicationController
      include Namer
      skip_before_filter :verify_authenticity_token
      allow_oauth!

      def create
        #validate phone
        phone = params[:phone].strip.gsub(/\D/, '') || ''
        if !phone || phone.empty?
          return render_response false, 'Missing or invalid phone'
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
        
        #generate share code
        share_code = loop do
          code = (0...4).map { ('A'..'Z').to_a[rand(26)] }.join
          break code unless Share.exists?(share_code: code)
        end
        
        #create share and send sms
        if Share.create({user_id: inviter.id, phone: phone, share_code: share_code})
               
          message_body = "#{inviter_name} thought you might enjoy our app!\n\n"
          message_body += "Please install the app and SIGN UP by clicking this link:\nhttp://bit.ly/1M3Xf5Q\n\n"
          message_body += "**Important Note: Make sure to enter the share code:\n"
          message_body += '"' + "#{share_code}" +'"' + "\n\n"
          message_body += "The app is as simple as:\n"
          message_body += " 1) Take a picture of the transaction\n"
          message_body += "2) Talk about the transaction (as if you were telling your accountant about it)\n"
          message_body += "3) Submit and you're done\n\n"
          message_body += "Yes, you read that right: Picture - Talk - Submit, that's it!\n\n"
          message_body += "Start by sending in some test submissions, and you'll have the hang of it in no time.\n\n"
          message_body += "Thanks,\n#{accountant_name}"

          if invitation = send_invite_sms(phone, message_body)
            return render_response true, 'SMS message sent successfully'
          else
            return render_response false, "SMS message send failed: #{invitation.inspect}"
          end
        else
          return render_response false, "There was an error creating the share"
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

      def send_invite_sms(dest_phone, sms_body)
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