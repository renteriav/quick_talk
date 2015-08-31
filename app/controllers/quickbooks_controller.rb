class QuickbooksController < ApplicationController
  
  rescue_from ::Exception, with: :error_occurred
  rescue_from Quickbooks::AuthorizationFailure, with: :unauthorized


  allow_oauth!
  skip_before_filter :verify_authenticity_token
  before_action :authenticate_user!, except: [:authenticate, :oauth_callback, :infusion]
  before_action :set_qb_service, only: [:create_purchase, :upload, :payment_methods, :purchase, :create_sale, :sale]
  layout 'layouts/quickbooks'

  def index
    session[:access_token] = params[:access_token]
  end
  
  def authenticate
      @access_token = session[:access_token]
      callback = oauth_callback_url(access_token: @access_token)
      token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback )
      session[:qb_request_token] = Marshal.dump(token)
      redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}&access_token=#{@access_token}") and return
  end

  def oauth_callback
    at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    qbo_client = QboClient.where("realm_id = ?", params['realmId']).first
    if qbo_client.nil?
      qbo_client = QboClient.new(realm_id: params['realmId'])
    end
      qbo_client.user_id = current_user.id
      qbo_client.token = at.token
      qbo_client.secret = at.secret
      qbo_client.token_expires_at = 6.months.from_now
      qbo_client.reconnect_token_at = 5.months.from_now + 3.days
      
    if qbo_client.save
      redirect_to quickbooks_success_path(access_token: session[:access_token]), notice: "Your QuickBooks account has been successfully linked."
    else 
      render action: "index"
    end
  end
  
  def disconnect    
  end
  
  
  def company_info
    @qbo_client = current_user.qbo_client
    if !@qbo_client.nil?
      service = Quickbooks::Service::CompanyInfo.new
      service.access_token = set_qb_service
      service.company_id = @qbo_client.realm_id
      @company = service.query(nil, :page => 1, :per_page => 500).first
      @company_name = @company.company_name
      return render_response(true, @company_name, 200)
    else
      return render_response(false, 'Unauthorized', 401)
    end
  end
  
  #expenses
  
  def get_accounts
    @qbo_client = current_user.qbo_client
    service = Quickbooks::Service::Account.new
    service.access_token = set_qb_service
    service.company_id = @qbo_client.realm_id

    accounts = service.query(nil, :page => 1, :per_page => 500)
    @accounts = accounts.entries
    @expense_categories = Hash.new
    @bank_accounts = Hash.new
    @accounts.each do |acc|
      if acc.classification && acc.classification.downcase == "expense"
        @expense_categories[acc.name] = acc.id.to_i
      elsif acc.account_type
        if acc.account_type.downcase == "bank" || acc.account_type.downcase == "credit card"
          @bank_accounts[acc.name] = acc.id.to_i
        end
      end
      @expense_categories = Hash[@expense_categories.sort]
      @bank_accounts = Hash[@bank_accounts.sort]
    end
  end
  
  def expense_categories
    if get_accounts
      render_response(true, @expense_categories, 200)
    else
      render_response(false, 'There has been an error', 500)
    end
  end
  
  def bank_accounts
    if get_accounts
      render_response(true, @bank_accounts, 200)
    else
      render_response(false, 'There has been an error', 500)
    end
  end
  
  def vendors
    if get_vendors
      render_response(true, @vendors, 200)
    else
      render_response(false, 'There has been an error', 500)
    end
  end
  
  def get_vendors
    @qbo_client = current_user.qbo_client
    service = Quickbooks::Service::Vendor.new
    service.access_token = set_qb_service
    service.company_id = @qbo_client.realm_id

    vendors = service.query(nil, :page => 1, :per_page => 500)
    @vendors_entries = vendors.entries
    @vendors = Hash.new
    @vendors_entries.each do |vendor|
      if !vendor.display_name.nil?
        @vendors[vendor.display_name] = vendor.id.to_i
      end   
    end
    @vendors = Hash[@vendors.sort]
  end
  
  def purchase
    @qbo_client = current_user.qbo_client
    @realm_id = @qbo_client.realm_id
    get_accounts
    get_vendors   
  end

  def create_purchase
    @qbo_client = current_user.qbo_client
    
    if params[:date]
      date = params[:date]
    end
    if params[:expense_category]
      expense_category_id = params[:expense_category]
    end
    if params[:bank_account]
      bank_account_id = params[:bank_account]
    end
    if params[:amount]
      amount = params[:amount]
    end
    if params[:payee]
      entity_ref_id = params[:payee]
    end
    if params[:description]
      description = params[:description]
    end

    purchase = Quickbooks::Model::Purchase.new
    service = Quickbooks::Service::Purchase.new
    service.access_token = set_qb_service
    service.company_id = @qbo_client.realm_id

    line_item = Quickbooks::Model::PurchaseLineItem.new
    #line_item.description = description
    line_item.amount = amount

    line_item.account_based_expense! do |account|
      account_ref = Quickbooks::Model::BaseReference.new(expense_category_id)
      account.account_ref = account_ref
    end
    purchase.line_items << line_item
    
    entity_ref = Quickbooks::Model::BaseReference.new(entity_ref_id)
    purchase.entity_ref = entity_ref
    
    purchase.payment_type = "Cash"
    purchase.txn_date = date
    purchase.private_note = description
    account_ref = Quickbooks::Model::BaseReference.new(bank_account_id)
    purchase.account_ref = account_ref
    if @created_purchase = service.create(purchase)
      @id = @created_purchase.id
      vendor_service = Quickbooks::Service::Vendor.new
      vendor_service.access_token = set_qb_service
      vendor_service.company_id = @qbo_client.realm_id
      vendor = vendor_service.fetch_by_id(entity_ref_id)
      file_name = "#{vendor.display_name}-#{Time.now.strftime("%m-%d-%Y")}" 
      upload(@id, "Purchase", file_name)
      
      render_response(true, "Upload succesfull", 200)
    else 
      render_response(false, "something went wrong", 500)
    end
  end
  
  #sales
  def get_payment_methods
    @qbo_client = current_user.qbo_client
    purchase = Quickbooks::Model::PaymentMethod.new
    service = Quickbooks::Service::PaymentMethod.new
    service.access_token = set_qb_service
    service.company_id = @qbo_client.realm_id
    payment_methods = service.query(nil, :page => 1, :per_page => 500)
    @payment_methods_entries = payment_methods.entries
    @payment_methods = Hash.new
    @payment_methods_entries.each do |pm|
    @payment_methods[pm.name] = pm.id.to_i 
    end
    @payment_methods = Hash[@payment_methods.sort]
  end
  
  def payment_methods
    if get_payment_methods
      render_response(true, @payment_methods, 200)
    else
      render_response(false, 'There has been an error', 500)
    end
  end
  
  def get_items
    @qbo_client = current_user.qbo_client
    purchase = Quickbooks::Model::Item.new
    service = Quickbooks::Service::Item.new
    service.access_token = set_qb_service
    service.company_id = @qbo_client.realm_id
    items = service.query(nil, :page => 1, :per_page => 500)
    @items_entries = items.entries
    @items = Hash.new
    @items_entries.each do |item|
    @items[item.name] = item.id.to_i 
    end
    @items = Hash[@items.sort]
  end
  
  def items
    if get_items
      render_response(true, @items, 200)
    else
      render_response(false, 'There has been an error', 500)
    end
  end
  
  def get_customers
    @qbo_client = current_user.qbo_client
    purchase = Quickbooks::Model::Customer.new
    service = Quickbooks::Service::Customer.new
    service.access_token = set_qb_service
    service.company_id = @qbo_client.realm_id
    customers = service.query(nil, :page => 1, :per_page => 500)
    @customers_entries = customers.entries
    @customers = Hash.new
    @customers_entries.each do |customer|
    @customers[customer.display_name] = customer.id.to_i 
    end
    @customers = Hash[@customers.sort]
  end
  
  def customers
    if get_customers
      render_response(true, @customers, 200)
    else
      render_response(false, 'There has been an error', 500)
    end
  end
  
  def sale
    @qbo_client = current_user.qbo_client
    @realm_id = @qbo_client.realm_id
    get_customers
    get_payment_methods
    get_items
  end

  def create_sale
    @qbo_client = current_user.qbo_client
    
    if params[:date]
      date = params[:date]
    end
    if params[:customer]
      customer_id = params[:customer]
    end
    if params[:method]
      method_id = params[:method]
    end
    if params[:amount]
      amount = params[:amount]
    end
    if params[:item]
      item_id = params[:item]
    end
    if params[:description]
      description = params[:description]
    end

    sale = Quickbooks::Model::SalesReceipt.new
    service = Quickbooks::Service::SalesReceipt.new
    service.access_token = set_qb_service
    service.company_id = @qbo_client.realm_id

    line = Quickbooks::Model::Line.new
    #line.description = description
    line.amount = amount
    
    sales_item_line_detail = Quickbooks::Model::SalesItemLineDetail.new
    sales_item_line_detail.item_ref = Quickbooks::Model::BaseReference.new(item_id)
    
    line.sales_item_line_detail = sales_item_line_detail
    line.detail_type = "SalesItemLineDetail"
    sale.line_items << line
    
    sale.txn_date = date

    payment_method_ref = Quickbooks::Model::BaseReference.new(method_id)
    sale.payment_method_ref = payment_method_ref
    
    customer_ref = Quickbooks::Model::BaseReference.new(customer_id)
    sale.customer_ref = customer_ref
    
    customer_service = Quickbooks::Service::Customer.new
    customer_service.access_token = set_qb_service
    customer_service.company_id = @qbo_client.realm_id
    customer = customer_service.fetch_by_id(customer_id)
    email = customer.primary_email_address
    sale.bill_email = email
    sale.private_note = description

    if @created_sale = service.create(sale)
      @id = @created_sale.id
      @file_name = "#{customer.display_name}-#{Time.now.strftime("%m-%d-%Y")}" 
      upload(@id, "SalesReceipt", @file_name)
      
      sales_receipt_service = Quickbooks::Service::SalesReceipt.new
      sales_receipt_service.access_token = set_qb_service
      sales_receipt_service.company_id = @qbo_client.realm_id
      sales_receipt = sales_receipt_service.fetch_by_id(@id)
      sent_receipt = sales_receipt_service.mail(sales_receipt.id, email.address)

      puts sent_receipt.email_status
      puts sent_receipt.delivery_info.delivery_time
      puts "#{@file_name}"

      render_response(true, "Upload succesfull", 200)
    else 
      render_response(false, "something went wrong", 500)
    end
  end
 
  #upload
  def upload(reference_id, entity_type, file_name)
    @qbo_client = current_user.qbo_client
    meta = Quickbooks::Model::Attachable.new
    entity = Quickbooks::Model::BaseReference.new(reference_id)
    entity.type = entity_type
    meta.attachable_ref = Quickbooks::Model::AttachableRef.new(entity)
    meta.attachable_ref.include_on_send = true
    meta.file_name = file_name
    @upload_service = Quickbooks::Service::Upload.new
    @upload_service.access_token = set_qb_service
    @upload_service.company_id = @qbo_client.realm_id
    # args:
    #     local-path to file
    #     file mime-type
    #     (optional) instance of Quickbooks::Model::Attachable - metadata
    if params[:file]
      path = params[:file].path
      puts "#{params[:file].path}"
      result = @upload_service.upload(path, "image/jpeg", meta)
    else
      puts"no path"
    end
  end
  
  def infusion
  end

  private

  def set_qb_service
    client = current_user.qbo_client
    token = client.token
    secret = client.secret
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, token, secret)
  end
  
  protected
  
  def render_response success, message, status
    output = {
      success: success,
      message: message,
      status: status
    }
    return render json: output.as_json
  end

  def unauthorized(exception)
    render_response(false, exception.message, 401)
  end

  def error_occurred(exception)
    render_response(false, exception.message, 500)
  end
  
end