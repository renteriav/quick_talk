module Api
  module V1
    class ShareController < ApplicationController
      skip_before_filter :verify_authenticity_token
      skip_before_action :authenticate_or_passthrough, only: [:promo_submit]

      def create
        guid = params[:guid].strip || ''
        if !guid || guid.empty?
          return render_response false, 'Missing or invalid guid'
        end

        phone = params[:phone].strip.gsub(/\D/, '') || ''
        if !phone || phone.empty?
          return render_response false, 'Missing or invalid phone'
        end

        inviter = User.where("guid = ? OR guid_alt = ?", guid, guid)
        if !inviter.any?
          return render_response false, 'Invalid guid'
        else
          inviter = inviter.first
        end

        invitee_phone = Profile.where({ phone: phone })
        if invitee_phone.any?
          return render_response false, 'Whoops, your friend already has an account!'
          #else
          #invitee = invitee.first
        end

        if inviter.is_accountant?
          accountant = inviter
        else
          accountant = inviter.get_accountant
        end

        if !accountant
          return render_response false, 'No accountant found for inviting user'
        end

        # at this point we have a phone, accountant, inviter, and invitee
=begin
        nu_email = "phone_#{phone}@autokept.com"
        nu_phone = phone
        nu_pass = phone[-4,4]
        nu_guid = generate_guid(nu_email, nu_pass)
        nu_guid_alt = generate_guid(nu_phone, nu_pass)
        invitee = User.new({
          email: nu_email,
          phone: nu_phone,
          password: nu_pass,
          password_confirmation: nu_pass,
          guid: nu_guid,
          guid_alt: nu_guid_alt
        })
        invitee.roles = ["business_client"]
        if invitee.save!
          
          invitee.group_memberships.create({ group_id: 3 })
          accountant.relationships.create({ client_id: invitee.id })
          accountant.save!
          invitee.save!
          profile = Profile.create({user_id: invitee.id, phone: nu_phone, show_personal_info_form: true })
        
=end
          share = Share.create({user_id: inviter.id, phone: phone, shared_at: Time.now })
          
          inviter_name = inviter.profile.first || inviter.email
        
          template = accountant.templates.where({style: "invitation_text"}).first
          if template.nil?
            template = Template.where({style: "invitation_text", user_id: 4}).first
          end
               
          message_body = "#{template.salutation}\n"
          message_body += "#{inviter_name} #{template.body_one}\n\n"
          message_body += "Please install the app and SIGN UP by clicking this link:\nhttp://bit.ly/1M3Xf5Q\n\n"
          message_body += "**Important Note: Make sure to enter phone number #{formated_phone phone} on the registration form.\n\n"
          message_body += "#{template.body_two}\n\n#{template.closing}\n#{signature_value('invitation_text', inviter)}"

          if temp = send_invite_sms(phone, message_body)
            return render_response true, 'SMS message sent successfully'
          else
            return render_response false, "SMS message send failed: #{temp.inspect}"
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


      def promo_submit
        number = params[:number].gsub(/[()-]/,'')
        template = Template.where({user_id: 4, style: "invitation_text"}).first
        message_body = "Thanks for your interest in AutoKept!\n\n"
        message_body += "Please install the app and SIGN UP by clicking this link:\nhttp://bit.ly/1M3Xf5Q\n\n"
        message_body += "**Important Note: Make sure to enter phone number #{params[:number]} on the registration form.\n\n"
        message_body += "#{template.body_two}\n\n#{template.closing}\n#{template.signature}"

        if send_invite_sms(number, message_body)
          page = PromoPage.find(params[:page])
          promo_share = PromoShare.where(phone: number).last
          if promo_share.nil?
            page.text_count += 1
            page.save
            PromoShare.create(phone: number, promo_page_id: page.id)
          end

          respond_to do |format|
            format.js {render template: 'promo/success'}
            format.html {redirect_to :back}
          end          
          return
        else
          respond_to do |format|
            format.js {render template: 'promo/invalid'}
            format.html {redirect_to :back}
          end
          return
        end
      end

      def send_invite_sms(dest_phone, sms_body)
        require 'twilio-ruby'
        
        account_sid = 'ACb5bfeb67ceedd54abb7594eb7842955f'
        auth_token = 'f01d5c5b83934c17e1feadc27639cbc7'
  
        origin_phone = '+15203895694'
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