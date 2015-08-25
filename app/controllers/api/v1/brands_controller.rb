module Api
  module V1
    class BrandsController < ApplicationController
      skip_before_filter :verify_authenticity_token
      allow_oauth!

      def index
      end

      def show

        client = current_user

        accountant = current_user
        if accountant
          if accountant.brand
            brand = accountant.brand
            created_at = brand.created_at
            updated_at = brand.updated_at
            
            message = {
              user_id: brand.user_id,
              logo_image: brand.logo_image.url(:small),
              profile_image: brand.profile_image.url(:small),
              company_name: brand.company_name,
              brand_phone: brand.brand_phone,
              brand_website: brand.brand_website,
              brand_email: brand.brand_email,
              line_one: brand.line_one,
              line_two: brand.line_two,
              created_at: created_at,
              updated_at: updated_at
            }.as_json
            render_response true, message, 123
          else
            render_response(false, 'Accountant has no brand configured', nil)
          end
        else
          render_response(false, 'User has no accountant assigned', nil)
        end
      end

      private

      def render_response success, message, access_token
        output = {
          success: success,
          message: message,
          access_token: access_token
        }
        return render json: output.as_json
      end

    end
  end
end