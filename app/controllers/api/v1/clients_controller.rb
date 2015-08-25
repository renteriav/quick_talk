module Api
  module V1
    class ClientsController < ApplicationController

      def toggle_status
        combo_id = params[:combo_id]
        guid, resource_id = combo_id.split('~')
        users = User.where({ guid: guid })
        if !users.any?
          return render_response false, 'User not found', nil
        end
        user = users.first
        resource = User.find(resource_id)
        if resource
          rel = Relationship.where({ user_id: user.id, client_id: resource.id }).first
          if rel
            if rel.status == 'inactive'
              rel.status = 'active'
            else
              rel.status = 'inactive'
            end
            if rel.save!
              return render_response true, 'Relationship status updated successfully', nil
            else
              return render_response false, 'Could not update relationship', nil
            end
          else
            return render_response false, 'Client relationship not found', nil
          end
        else
          return render_response false, 'Resource not found', nil
        end
            
      end
      
      def toggle_mileage_status
        users = User.where({ guid: params[:guid] })
        if !users.any?
          return render_response false, 'User not found', nil
        end
        user = users.first
        profile = user.profile
        if profile
          if profile.mileage_paid == true
            profile.mileage_paid = false
          else
            profile.mileage_paid = true
          end
          if profile.save!
            return render_response true, 'Mileage page access successfully granted', nil
          else
            return render_response false, 'Mileage page access could not be granted', nil
          end
        else
          return render_response false, 'Client profile not found', nil
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

    end
  end
end