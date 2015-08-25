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
  
  get 'dashboard', to: 'dashboard#index'
  
  scope :quickbooks do
    get '/', to: 'quickbooks#index', as: :quickbooks_index
    get '/authenticate', to: 'quickbooks#authenticate', as: :quickbooks_authenticate
    get :oauth_callback, to: 'quickbooks#oauth_callback'
    post :create_purchase, to: 'quickbooks#create_purchase'
    get :purchase, to: 'quickbooks#purchase'
    get :success, to: 'quickbooks#success', as: :quickbooks_success
    get :expense_categories, to: 'quickbooks#expense_categories', as: :quickbooks_expense_categories
    get :bank_accounts, to: 'quickbooks#bank_accounts', as: :quickbooks_bank_accounts
    get :vendors, to: 'quickbooks#vendors', as: :quickbooks_vendors
  end

  # mobile uploader endpoint
  namespace :api do
    namespace :v1 do
      post 'clients/:combo_id/toggle_status', to: 'clients#toggle_status'
      match :share, to: 'share#create', via: [ :get, :post ]
      match :check_ua, to: 'share#detect_and_redirect', via: [ :get, :post ]
      resources :uploads
      match :submit, to: 'uploads#submit', via: [ :post ]
      resource :user, only: [:edit] do
        collection do
          patch 'update'
        end
      end
      resources :users, except: [ :show ]
      scope :users do
        match :auth, to: 'users#authenticate_by_un_and_pw', via: [ :get, :post ]
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
      scope :profiles do
        match 'update', to: 'profiles#update', via: [ :put, :post ]
      end
      get 'profile', to: 'profiles#show'
    end
  end
end

