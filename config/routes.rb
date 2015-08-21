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
end