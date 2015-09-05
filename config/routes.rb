Rails.application.routes.draw do
  root to: 'dashboard#index'
  mount_opro_oauth
  devise_for :users
  post 'users/sign_up', to: 'users#sign_up'
  
  resources :users do
    resource :brand do
      delete :delete_logo, to: 'brands#delete_logo'
      delete :delete_profile_image, to: 'brands#delete_profile_image'
    end
  end
  
  resources :shares
  
  get 'onboarding', to: 'brands#onboarding'
  
  get 'dashboard', to: 'dashboard#index'
  
  scope :quickbooks do
    get '/', to: 'quickbooks#index', as: :quickbooks_index
    get '/authenticate', to: 'quickbooks#authenticate', as: :quickbooks_authenticate
    get '/disconnect', to: 'quickbooks#disconnect', as: :quickbooks_disconnect
    get :oauth_callback, to: 'quickbooks#oauth_callback'
    get :success, to: 'quickbooks#success', as: :quickbooks_success
    get :new_customer, to: 'quickbooks#new_customer'
    post :create_vendor, to: 'quickbooks#create_vendor'
    get :new_vendor, to: 'quickbooks#new_vendor'
    post :create_customer, to: 'quickbooks#create_customer'
    get :purchase, to: 'quickbooks#purchase'
    post :create_purchase, to: 'quickbooks#create_purchase'
    get :sale, to: 'quickbooks#sale'
    post :create_sale, to: 'quickbooks#create_sale'  
    get :expense_categories, to: 'quickbooks#expense_categories', as: :quickbooks_expense_categories
    get :bank_accounts, to: 'quickbooks#bank_accounts', as: :quickbooks_bank_accounts
    get :vendors, to: 'quickbooks#vendors', as: :quickbooks_vendors
    get :payment_methods, to: 'quickbooks#payment_methods', as: :quickbooks_payment_methods
    get :items, to: 'quickbooks#items', as: :quickbooks_items
    get :customers, to: 'quickbooks#customers', as: :quickbooks_customers
    get :company_info, to: 'quickbooks#company_info', as: :quickbooks_company_info
    get :infusion, to: 'quickbooks#infusion', as: :quickbooks_infusion
    get :changed_entities, to: 'quickbooks#changed_entities', as: :quickbooks_changed_entities
  end

  # mobile uploader endpoint
  namespace :api do
    namespace :v1 do
      match :share, to: 'share#create', via: [ :get, :post ]
      match :check_ua, to: 'share#detect_and_redirect', via: [ :get, :post ]
      resources :users, except: [ :show ]
      scope :users do
        match :log_in, to: 'users#log_in', via: [ :post ]
        match :sign_up, to: 'users#sign_up', via: [ :post ]
      end
      resources :accountants, except: [ :show ]
      scope :accountants do
        post 'create', to: 'accountants#create'
      end
      scope :brands do
        get 'fetch', to: 'brands#show'
      end
    end
  end
end

