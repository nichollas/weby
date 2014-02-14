Weby::Application.routes.draw do
  constraints(Weby::Subdomain) do
    # Mount all engines here
    constraints(Weby::Extensions) do
      mount Feedback::Engine, :at => 'feedback'
      mount Acadufg::Engine, :at => 'acadufg'
    end

    get '/' => 'sites#show', as: :site
    get '/admin' => 'sites#admin', as: :site_admin
    get '/admin/edit' => 'sites#edit', as: :edit_site_admin
    put '/admin/edit' => 'sites#update', as: :edit_site_admin

    # routes to feed and atom
    match '/feed' => 'sites/pages#published', as: :site_feed,
      defaults: { format: 'rss', per_page: 10, page: 1 }
    
    resources :pages,
      as: :site_pages, 
      controller: "sites/pages", 
      only: [:index, :show] do
        collection do
          get :published, :events, :news
          post :sort
        end
      end

    resources :components,
      as: :site_components,
      controller: 'sites/components',
      only: [:show]

    post "count/:model/:id" => "application#count_click", :as => :count_click

    namespace :admin, module: 'sites/admin', as: :site_admin do

      # route to paginate
      match "banners/page/:page" => "banners#index"
      match "groups/page/:page" => "groups#index"
      match "repositories/page/:page" => "repositories#index"
      match "pages/page/:page" => "pages#index"

      get  "stats" => "statistics#index"
      get  'backups' => 'backups#index'
      get  'generate' => 'backups#generate'
      post 'import' => 'backups#import'

      resources :activity_records, only: [:index, :show]
      resources :banners do
        member do
          put :toggle
        end
      end
      resources :components do
        member do
          put :toggle
        end
        collection do
          post :sort
        end
      end
      resources :extensions
      resources :menus do
        resources :menu_items,
          controller: "menus/menu_items" do
            member do
              put :toggle
            end
            collection do
              post :change_order, :change_menu
            end
          end
      end
      resources :pages do
        member do
          put :toggle, :recover
        end
        collection do
          get :fronts, :recycle_bin
          post :sort
        end
      end
      resources :repositories do
        member do
          put :recover
        end
        collection do
          get :manage, :recycle_bin
        end
      end
      resources :roles do
        collection do
          put :index
        end
      end
      resources :styles do
        member do
          put :toggle, :copy, :follow, :unfollow
        end
        collection do
          post :sort
        end
      end
      resources :users, only: [] do
        collection do
          get :manage_roles
          post :change_roles
        end
      end
    end
  end

  root :to => "sites#index"

  constraints(Weby::GlobalDomain) do
    #rota para paginação
    match "sites/page/:page" => "sites#index", :as => :sites

    match "/admin" => "application#admin"

    namespace :admin do
      match "settings" => "settings#index", :via => [:get, :put]
      resources :users do
        collection do
          get :manage_roles
          post :change_roles
        end
        member do
          put :toggle
          put :set_admin
        end
      end
      resources :roles, except: :show do
        collection do
          put :index
          post :sort
        end
      end
      resources :sites, except: [:show]
      resources :groupings, except: [:show]
      resources :notifications
      resources :activity_records, only: [:index, :show, :destroy]

      get "stats" => "statistics#index"

      # route to paginate
      match "users/page/:page" => "users#index"
      match "sites/page/:page" => "sites#index"
    end
  end

  # routes to profiles
  resources :profiles, only: [:show, :edit, :update] do
    member do
      get :history
    end
  end

  resources :notifications, only: [:index, :show] do
    collection do
      post :mark_as_read
    end
  end

  # defaults devise routes
  devise_for :users, path: '/', skip: [:sessions, :registrations, :passwords]

  # customize devise routes
  devise_scope :user do
    # routes to session
    delete 'logout'  => 'sessions#destroy'
    get    'login'   => 'sessions#new'
    post   'login'   => 'sessions#create'

    # routes to register
    get    'signup'  => 'devise/registrations#new'
    post   'signup'  => 'devise/registrations#create'

    # routes to password
    get  'forgot_password' => 'devise/passwords#new'
    post 'forgot_password' => 'devise/passwords#create'
    get  'reset_password'  => 'devise/passwords#edit'
    put  'reset_password'  => 'devise/passwords#update'
  end

  # route to about
  get "about" => "sites#about"

  match "robots.txt" => "sites#robots", :format => "txt"
  match "*not_found" => "application#render_404"
end
