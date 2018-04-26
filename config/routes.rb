Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  resources :support_sources
  resources :supportbee_support_sources
  resources :github_support_sources
  resources :frontapp_support_sources
  resources :rss_support_sources

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'dashboard#index'
  post 'dashboard/ignore' => 'dashboard#ignore'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  namespace :webhooks do
    scope :github, controller: :github_webhook do
      post 'hook'
    end
  end
  # post 'webhooks/github/:action' => 'webhooks/github_webhook'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase
  scope :admin, controller: :admin_area, as: :admin_area do
    get '/', action: 'index'
    %w(sync_github sync_supportbee sync_frontapp sync_rss).each do |action|
      post action
    end
  end

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
