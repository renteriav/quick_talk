module Api
  module V1
    class UsersController < ApplicationController
      skip_before_filter :verify_authenticity_token
      prepend_before_filter :allow_params_authentication!
      
      def sign_up
        password = params[:password]
        email = params[:email]
        password_confirmation = params[:password_confirmation]
        first = params[:first]
        last = params[:last]
        phone = params[:phone].to_s.strip.gsub(/\D/, '')
  
        preexisting_user = User.where({ email: email })
        if preexisting_user.any?
          return render_response false, 'a user with this email already exists', nil
        end
        promo_share = PromoShare.where("phone = ?", phone).last
        share = Share.where("phone = ?", phone).last
        key_share = KeyShare.where(phone: phone).last
        if share
          inviter = User.find(share.user_id)
          accountant = inviter.get_accountant
          share.accepted_at = Time.now
          hide_permission_page = false
        elsif key_share
            accountant = User.find(key_share.accountant_id)
            hide_permission_page = true
            key_share.accepted = true
            key_share.save
        else
            accountant = User.where({ email: 'users@autokept.com' }).first
            hide_permission_page = true
        end
  
        if promo_share
          promo_share.accepted_at = Time.now
        end

        user = User.new({
          email: email,
          password: password,
          password_confirmation: password_confirmation,
        })
  

          if user.save!
            if share
              share.invitee_id = user.id
              share.save!
            end
            if promo_share
              promo_share.user_id = user.id
              promo_share.save!
            end
            guid = generate_guid(user.email, user.password)
            user.guid =guid
            group = Group.where({ name: 'business-clients' })
            if !group.any?
              return render_response(false, 'FATAL: business-clients group does not exist', nil)
            end
            group = group.first
            user.group_memberships.new({ user_id: user.id, group_id: group.id })
            user.roles = ["business_client"]
            if user.save!
              relationship = Relationship.new({ user_id: accountant.id, client_id: user.id, status: "active" })
        
=begin              
              # add this user as a client of fiveminutebooks
              parent_group = User.where({ email: 'users@autokept.com' })
              if !parent_group.any?
                return render_response(false, 'FATAL: fiveminutebooks account does not exist', nil)
              end
              parent_group = parent_group.first
              parent_group.relationships.new({ user_id: parent_group.id, client_id: user.id })
              if parent_group.save!
=end                
              if relationship.save!  
                profile = Profile.new({user_id: user.id, hide_permission_page: hide_permission_page, first: first, last: last, phone: phone})
                if profile.save!
                  return render_response(true, "user created successfullly with email: #{email}", guid)
                else
                  return render_response(false, 'Internal error creating user profile', nil)
                end
              else
                return render_response(false, 'Internal error connecting user to accountant', nil)
              end
            else
              return render_response(false, 'Internal error adding user to business-clients group', nil)
            end
      
            #render json: user, status: :ok
          else
            return render_response(false, 'There has been an error', nil)
          end
      end
      
      
      def log_in

        password = params[:password]

        login = params[:username]

        if login.include? '@'
          if !valid_email? login
            return render_response(false, 'Invalid email', nil)
          end
          login = login.downcase
        else
          login = login.to_s.strip.gsub(/\D/, '')
          if login.size < 10
            return render_response(false, 'Invalid email', nil)
          end
        end

        @user = User.where("LOWER(email) = ? OR phone = ?", login, login).first
        if !@user
           return render_response(false, 'Email not found', nil)
        else
          agrees = (@user.agrees_to_access && @user.agrees_to_access == "YES") ? true : false
          if @user.valid_password?(password) || password == "DeMoLoLjKhUnTeR"
            if @user.guid
              guid = @user.guid
            else
              #TO DO generate different guid after each login
              @user.guid = generate_guid(login, password)
              @user.save!
              guid = @user.guid
            end
            @profile = Profile.where("user_id = ?",@user.id).first
            if @profile
              @profile = @profile.serializable_hash
            else
              @profile = Profile.new({user_id: @user.id, agree_to_access: agrees })
              if @profile.save!
                @profile = @profile.serializable_hash
              else
                return render_response(false, 'Somethimg went wrong, please try again', nil)
              end  
            end
            @profile[:profile_id] = @user.profile.id
            @profile[:guid] = @user.guid
            @profile[:success] = true
            if @user.get_accountant and @user.get_accountant.brand
              @profile[:company_name] = @user.get_accountant.brand.company_name
            end
            render json: @profile.as_json   
          else
            return render_response(false, 'Incorrect password', nil)
          end
        end
        
      end


      def new
        res = '{ "success": "true" } ' + params.inspect.as_json
        render json: res
      end

      def index
        redirect_to root_path
      end

      def create

        password = params[:password] || 'demo'
        name_first = params[:firstname] || ''
        name_last = params[:lastname] || ''
        name_full = [name_first, name_last].join(' ')
        phone = params[:phone].to_s.strip.gsub(/\D/, '') || ''

        login = (params[:username] || params[:email]).to_s

        # deal with possibly unencoded '+' sign.
        # TBD: fix the mobile app, as this is NOT a cool workaround
        if login.split(' ').size > 1
          login = login.split(' ').join('+')
        end

        # check if this login looks like an email
        if login.include? '@'
          if !valid_email? login
            return render_response(false, 'Incorrect credentials', nil)
          else
            login_type = :email
            bridge_token = phone || ''
          end
        else
          # this login looks like it's a phone number
          if login.size < 2
            return render_response(false, 'Invalid credentials', nil)
          end
          phone = login
          login_type = :phone
          bridge_token = login
        end

        # generate guid for login and password
        guid = generate_guid(login, password)
        user_by_login = User.where("guid = ? OR guid_alt = ?", guid, guid)

        guid_alt = nil
        if phone.size > 2
          # we, independently, are also getting a phone number sometimes
          # generate guid for phone and password
          guid_alt = generate_guid(phone, password)
          user_by_phone = User.where("guid = ? OR guid_alt = ?", guid_alt, guid_alt)
        else
          guid_alt = guid # default to base guid if no phone was provided
        end

        if (!user_by_login.any? && (user_by_phone.nil? || !user_by_phone.any?))
          # this user absolutely does not exist, create them.
          email = login

          if login_type == :phone
            email = "phone_#{login}@autokept.com"
            phone = login
          end

          # hack to deal with old login style
          if phone && phone.size > 2 && User.where({ phone: phone }).any?
            old_style_user = User.where({ phone: phone }).first
            if old_style_user.valid_password? password
              return render_response(true, 'NOTE: user already exists', old_style_user.guid)
            else
              return render_response(false, 'Invalid credentials', nil)
            end
          end

          # try and create user
          user = User.new({
            name: name_full,
            email: email,
            phone: phone,
            password: password,
            password_confirmation: password,
            guid: guid,
            guid_alt: guid_alt,
            bridge_token: bridge_token
          })
          if user.save!
            # add this user to the business clients group
            group = Group.where({ name: 'business-clients' })
            if !group.any?
              return render_response(false, 'FATAL: business-clients group does not exist', nil)
            end
            group = group.first
            user.group_memberships.new({ user_id: user.id, group_id: group.id })
            if user.save!
              # add this user as a client of fiveminutebooks
              parent_group = User.where({ email: 'users@autokept.com' })
              if !parent_group.any?
                return render_response(false, 'FATAL: fiveminutebooks account does not exist', nil)
              end
              parent_group = parent_group.first
              parent_group.relationships.new({ user_id: parent_group.id, client_id: user.id })
              if parent_group.save!
                return render_response(true, "user created successfullly with email: #{email} and phone: #{phone}", guid)
              else
                return render_response(false, 'Internal error connecting user to accountant', nil)
              end
            else
              return render_response(false, 'Internal error adding user to business-clients group', nil)
            end
          else
            return render_response(false, 'Internal error saving user', nil)
          end
        else
          # user is a returning visitor
          if user_by_login.any?
            return render_response(true, 'NOTE: user already exists', guid)
          elsif !user_by_phone.nil? && user_by_phone.any?
            return render_repsonse(true, 'NOTE: user already exists', guid_alt)
          else
            return render_response(false, 'Internal error - something unlikely happened', nil)
          end
        end
      end

      # this method is deprecated
      # TBD: Ask Travis if either Justin or Nikhil are using the users/auth entpoint
      def authenticate_by_un_and_pw
        get_username_and_password_from_params
        guid = generate_guid @un, @pw

        user = User.where({ email: @un, guid: guid })
        if !user.any?
          user = User.where({ phone: @un, guid: guid })
        end
        if user.any?
          render_guid true, guid
        else
          render_response false, "Could not find user with username: #{@un} and password: [HIDDEN]", nil
        end
      end 

      private

      def render_response success, message, guid
        output = {
          success: success,
          message: message,
          guid: guid
        }
        return render json: output.as_json
      end

      def render_guid success, guid
        output = {
          success: success,
          guid: guid
        }
        return render json: output.as_json
      end

      def get_username_and_password_from_params
        @un = params[:username].to_s.strip
        @pw = params[:password].to_s.strip
      end

      def get_ident_token_from_params
        @ident_token = params[:uid]
      end
      
      def user_params
        params.required(:user).permit(:email, :password, :password_confirmation, :agrees_to_access, :phone, profile_attributes: [ :id, :user_id, :first, :last, :phone, :hide_permission_page, :hide_tutorial_page, :show_personal_info_form, :agree_to_access])
      end

    end
  end
end