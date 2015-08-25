class BrandsController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [:onboarding]
  layout 'layouts/empty', :only => [:onboarding]
  
  def index
    get_brand
  end

  def edit
    get_brand
    if !@brand.logo_image_url.nil?
      if @brand.logo_image_url.length > 0
        @logo_image = @brand.logo_image.url :small
      end
    else
      @logo_image = @brand.company_name
    end     
  end

  def create
    # update handles everything
    @brand = current_user.build_brand(brand_params)
    respond_to do |format|
      if @brand.save
        format.html { redirect_to edit_user_brand_path(current_user.id), notice: 'Brand was successfully created.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def update
    @brand = current_user.brand
    respond_to do |format|
      if @brand.update_attributes(brand_params)
        #if params[:email_onboarding]
          #user = User.find(params[:user_id])
          #send_onboard_text
          #InvitationMailer.client_invite(user.email, user).deliver
          #user.guid_alt = nil
          #user.save
          #format.html {redirect_to root_path}
          #else
          format.js {render layout: false, action: 'update'}
          format.html { render action: "edit"}  
          flash[:notice] = "App styles saved successfully"
          #end
      else
        format.html { render action: "edit" }
        format.js { render action: 'update' }
      end
    end
  end
  
  def onboarding
    if params[:guid]
      user = User.where("guid_alt = ?", params[:guid])
      if user.any?
        @accountant = user.first
        if @accountant.brand
          @brand = @accountant.brand
        else
          @brand = @accountant.build_brand(brand_params)
        end
        
      else
        redirect_to root_path
        authenticate_user!
      end
    else
      redirect_to root_path
      authenticate_user!
    end
  end
  
  def send_onboard_text
    if params[:onboard_phone] and params[:onboard_phone].to_s.strip.gsub(/\D/, '').size == 10
    phone = params[:onboard_phone]
    @user = User.find(params[:user_id])
    @name = @user.profile.first || @user.email
    sms_body = "Hi #{@name},\n\n"
    sms_body += "Are you ready to check out your branded app on your own phone?\n\nWe thought so too!\n\nClick this link to install the app:\nhttp://bit.ly/1M3Xf5Q\n\nAnd log in with:\n"
    sms_body += "Username: #{@user.email}\n"
    sms_body += "Password: (the same password you use when you log into the online Web Portal)\n\n"
    sms_body += "If you'd like any changes to your app, just go to the 'App Studio' page on your Web Portal and make the changes, then re-open the app to see the changes happen immediately.\n\nHave some fun with it!\n\nThanks again,\nThe AutoKept Team"
    end

    if phone
      send_sms(phone, sms_body)
    end
  end
  
  def delete_logo
    @brand = Brand.find_by_id(params[:brand_id])
    @brand.remove_logo_image!
    respond_to do |format|
      if @brand.save
        format.js {render layout: false, action: 'delete_logo'}
        format.html { render action: "edit" }
      else
        format.js {render layout: false, action: 'error'}
        format.html { render action: "edit" }
      end
    end
  end
  
  def delete_profile_image
    @brand = Brand.find_by_id(params[:brand_id])
    @brand.remove_profile_image!
    respond_to do |format|
      if @brand.save
        format.js {render layout: false, action: 'delete_profile_image'}
        format.html { render action: "edit" }
      else
        format.js {render layout: false, action: 'error'}
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    get_brand
    @brand.destroy
    current_user.build_brand
    current_user.save
    redirect_to action: :edit
  end


  def admin_update
    @brand = Brand.find(params[:id])
    params[:brand][:keyword] = params[:brand][:keyword].downcase if params[:brand][:keyword]

    existing_brand = Brand.where(keyword: params[:brand][:keyword]).first
    if existing_brand.nil?
      @brand.update_attributes(params.require(:brand).permit(:keyword))
    else
      if existing_brand.id != params[:id].to_i
        flash[:notice] = "Another brand already has that keyword"
      end
    end
    redirect_to :back
  end

  private

  def get_brand
    if current_user.brand
      @brand = current_user.brand 
    else
      @brand = current_user.build_brand
    end
    authorize! :read, @brand
  end
  
  def brand_params
    params.require(:brand).permit(:user_id, :company_name, :profile_image, :logo_image, :brand_email, :brand_website, :brand_phone, :line_one, :line_two)
  end   

end