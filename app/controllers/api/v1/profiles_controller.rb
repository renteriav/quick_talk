module Api
  module V1
    class ProfilesController < ApplicationController
      skip_before_filter :verify_authenticity_token
      
      def show
        if current_user
          @user = current_user
          if @user.profile
            @profile = @user.profile.serializable_hash
          else
            @profile = Hash.new
          end
          @profile[:company_name] = ""
          if @accountant = @user.get_accountant
              @profile[:has_accountant] = true
            if @accountant.brand
              @company_name = @accountant.brand.company_name
              @profile[:company_name] = @company_name
              @company_logo = @accountant.brand.image_header_url
              @profile[:company_image_header] = @company_logo
              @company_profile_picture = @accountant.brand.image_avatar_url
              @profile[:company_image_avatar] = @company_profile_picture
            else 
              @profile[:company_name] = @accountant.profile.full_name
            end
          else
            @profile[:has_accountant] = false
          end
            
          render :json => @profile
        end
      end
      
      def update
        if current_user
          @user = current_user
          if !@user.profile
            @profile = Profile.new
            @profile.user_id = current_user.id
            @profile.save
          else
          @profile = @user.profile
          end
          if @profile.update_attributes(profile_params)
            format.json { render json: @profile, status: :ok }
          else
            format.json { render json: @profile.errors, status: :unprocessable_entity }
          end
        end
      end
      
      private
      
      def profile_params
        params.require(:profile).permit(:user_id, :first, :last, :phone, :street, :city, :state, :zip, :show_personal_info_form, :hide_permission_page, :hide_tutorial_page, :agree_to_access) 
      end

    end
  end
end