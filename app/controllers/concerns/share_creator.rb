module ShareCreator
  extend ActiveSupport::Concern

  included do
    helper_method :create_share
  end 
  
  def share_message_body(inviter_name, share_code, accountant_name)
       
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
      
      return message_body
  end
  
end