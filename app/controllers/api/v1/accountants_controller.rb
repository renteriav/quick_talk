module Api
  module V1
    class AccountantsController < ApplicationController
      skip_before_filter :verify_authenticity_token
      skip_before_filter :authenticate_user!
      prepend_before_filter :allow_params_authentication!


      def index
      end


      def new
      end

      def create
        # redirect if no token
        if !params[:token]
          authenticate_user!
        end

        if params[:token] != sender_token
          authenticate_user!
        end

        # break if no email+password
        if !(params[:email] && params[:password])
          notify_me('email or password were not passed in', nil, params)
          return render_response false, "email and password are required"
        end

        email = params[:email].to_s.downcase.strip
        password = params[:password].to_s.strip
        first_name = params[:firstname] || ''
        last_name = params[:lastname] || ''
        company_name = params[:companyname] || ''
        phone = params[:phone].to_s.strip.gsub(/\D/, '') || ''
        #name_full = firstname
        #name_full = (firstname + ' ' + lastname) if !lastname.nil?

        guid = generate_guid(email, password)
        guid_alt = generate_guid(password, password)


=begin
        do_demo_user_check = true
        if phone.empty?
          do_demo_user_check = false
        else
          # see if this phone number exists in the system as a bridge user
          user = User.where({ bridge_token: phone })
          if user.any?
            user = user.last
            if user.is_accountant?
              notify_me('an accountant with this bridge token (phone) already exists', user, params)
              return render_response false, 'an accountant with this bridge token (phone) already exists'
            else
              demo_user = user
            end
          end
          guid_alt = generate_guid(phone, password)
        end

        if do_demo_user_check
          # look for demo user
          if demo_user
            demo_user = demo_user
            demo_user.email = "phone_#{phone}@autokept.com"
            demo_user.save!
          end
        else
          demo_user = nil
        end
=end
        # check if email already exists and change it if it does
        preexisting_user = User.where({ email: email })
        if preexisting_user.any?
          accountant = preexisting_user.first
          password = 'preexisting_user_password'
          #notify_me('a user with this email already exists and bridge_token does not match - no record created for accountant', pu, params)
         # return render_response false, 'a user with thie email already exists'
         
           #if pu.valid_password?(password)
            # accountant = pu
           #end
        else

        # create new accountant
        accountant = User.new({ 
          email: email,
          #name: name_full,
          #phone: phone,
          #bridge_token: phone,
          password: password,
          password_confirmation: password,
          guid: guid,
        })
        
        end
        
        # build accountant brand
        accountant.guid_alt = guid_alt
        accountant.share_token = SecureRandom.urlsafe_base64(9)
        accountant.build_brand({company_name: company_name})
        
        #accountant.brand.name = name_full
        #accountant.brand.company_name = company_name
        accountant.roles = ["accountant"]
        #accountant.brand.accountant_name = name_full
        if accountant.profile
          accountant.profile.first = first_name
          accountant.profile.last = last_name
          accountant.profile.phone = phone
          accountant.profile.agree_to_access = true
          accountant.profile.hide_onboarding = false
        else
          accountant.build_profile({first: first_name, last: last_name, phone: phone, agree_to_access: true})
        end

        if accountant.save!
          # add accountant to accountant group
          accountant_group = Group.where({ name: 'accountants' }).first
          #accountant.group_memberships.new({ group_id: accountant_group.id })
        else
          notify_me('could not successfully save accountant', accountant, params)
          return render_response false, 'could not successfully save accountant'
        end

        if accountant.save!

          #if demo_user
          relationships =  Relationship.where({client_id: accountant.id})
          if relationships
            relationships.destroy_all
          end
          accountant.relationships.new({ client_id: accountant.id, status: 'active' })
          if accountant.save!
            # YAAAAAAAY!   WORKED.
            InvitationMailer.accountant_signed_up(email, first_name, accountant.guid_alt, password).deliver
            
            url = "#{request.protocol}#{request.host_with_port}/marketing/1?tok=#{accountant.share_token}"
            accountant.profile.hour_check(accountant, url)
            
            return render_response true, 'accountant created and linked successfully'
          else
            notify_me('could not link up accountant to demo user', accountant, params)
            return render_response false, 'could not link up accountant to demo user'
          end

        else
          notify_me('could not successfully save accountant', accountant, params)
          return render_response false, 'could not successfully save accountant'
        end


      end

      def render_response success, message
        output = {
          success: success,
          message: message
        }
        render json: output.as_json
      end

      private

      def sender_token
        'qwoejg94t80q4t9gue0'
      end

      def notify_me message, attempted_user, details
        people_to_notify = ['twbeauli@mtu.edu']
        people_to_notify.each do |internal_email|
          NoticeMailer.generic_message(internal_email, message, attempted_user, details).deliver
        end
      end

    end
  end
end