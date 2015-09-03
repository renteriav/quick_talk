module Api
  module V1
    class AccountantsController < ApplicationController
      skip_before_filter :verify_authenticity_token
      skip_before_filter :authenticate_user!

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
          return render_response false, "email and password are required"
        end

        email = params[:email].to_s.downcase.strip
        password = params[:password].to_s.strip
        first = params[:first] || ''
        last = params[:last] || ''
        company_name = params[:company_name] || ''
        phone = params[:phone].to_s.strip.gsub(/\D/, '') || ''

        # check if email already exists and change it if it does
        preexisting_user = User.find_by email: email
        if preexisting_user
          accountant = preexisting_user
          accountant.first = first
          accountant.last = last
          accountant.phone = phone
          password = 'preexisting_user_password'
        else
        # create new accountant
        accountant = User.new({ 
          email: email,
          first: first,
          last: last,
          phone: phone,
          password: password,
          password_confirmation: password,
        })
        
        end
        
        #generate tokens
        accountant.share_token = generate_token
        accountant.single_use_token = generate_token
        
        # build accountant brand
        accountant.build_brand({company_name: company_name, brand_email: email, brand_phone: phone})
        accountant.roles = ["accountant", "client"]
        
        #destroy demo relationships and create relationship with self 
        relationships =  Relationship.where({client_id: accountant.id})
        if relationships
          relationships.destroy_all
        end
        accountant.relationships.build({ client_id: accountant.id })

        if accountant.save!
          access_token = accountant.single_use_token
         AccountantMailer.accountant_signed_up(email, access_token, first, password).deliver
         return render_response true, 'accountant created and linked successfully'
        else
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

    end
  end
end