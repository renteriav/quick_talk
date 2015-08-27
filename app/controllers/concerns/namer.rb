module Namer
  extend ActiveSupport::Concern

  included do
    helper_method :name_or_email
  end

  def name_or_email(user)
    if user.full_name != ""
      result = user.full_name
    else
      result = user.email
    end
    return result
  end
  
end