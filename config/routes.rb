Rails.application.routes.draw do
  get 'password_resets/new'

  get 'password_resets/edit'

  root                      'static_pages#home'
  get   'help'        =>    'static_pages#help'
  get   'about'       =>    'static_pages#about'
  get   'contact'     =>    'static_pages#contact'
  get   'signup'      =>    'static_pages#signup'
  get   'user_signup' =>    'users#new'
  get   'company_signup' => 'companies#new'
  get   'login'       =>    'sessions#new'
  get   'joblist'     =>    'job_postings#joblist'
  post  'login'       =>    'sessions#create'
  delete 'logout'      =>   'sessions#destroy'
  resources :users
  resources :companies
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :job_postings
  resources :applicants, only: [:create, :destroy]

end
