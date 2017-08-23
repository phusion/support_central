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

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  post 'webhooks/github/:action' => 'webhooks/github_webhook'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase
  post 'admin/sync_github' => 'admin_area#sync_github'
  post 'admin/sync_supportbee' => 'admin_area#sync_supportbee'
  post 'admin/sync_frontapp' => 'admin_area#sync_frontapp'
  post 'admin/sync_rss' => 'admin_area#sync_rss'
  get 'admin' => 'admin_area#index', as: :admin_area
  get 'admin(/:action)' => 'admin_area'

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
