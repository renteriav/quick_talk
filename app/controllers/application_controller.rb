class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout :layout_by_resource
  
  protected

  def layout_by_resource
    if devise_controller? && resource_name == :user && action_name == "new"
      "empty"
    else
      "application"
    end
  end
  
end
