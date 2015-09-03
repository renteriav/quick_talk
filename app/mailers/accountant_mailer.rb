class AccountantMailer < ActionMailer::Base
  default from: '"Support @ QuickTalk"<support@quicktalk.biz>'
  
  def accountant_signed_up email, access_token, first_name, pass
    @first_name = first_name.capitalize
    @email = email
    @access_token = access_token
    if pass == 'preexisting_user_password'
      @password = "(The password you use to sign in to the mobile app)"
    else
      @password = pass
    end
    mail(to: email, subject: "You're All Signed Up On QuickTalk!")
  end
  
  def client_invite recipient_email, user
    @user = user
    @recipient_email = recipient_email
    mail(to: @recipient_email, subject: "QuickTalk - Forward This To Your Clients")
  end

end
