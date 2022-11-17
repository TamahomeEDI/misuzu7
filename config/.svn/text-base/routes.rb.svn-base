Misuzu7::Application.routes.draw do
  resources :seisankankatukoujoumasuta
  resources :tantogroupmasuta
  # Del by nmhuyen 15/10/2012 for routes too long
  #resources :tantosyabetugamenmasuta
  #End Del
  # Add by nmhuyen 15/10/2012 for routes too long
  resources :mb005, :controller => "tantosyabetugamenmasuta"
  #End add

  # tantosya masuta
  resources :tantosyamasuta
  # menu masuta
  resources :menumasuta
  
  # 担当グループマスタ
  resources :mb001
  # 組織マスタ
   resources :pw_sosiki
  resources :m135
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
  match "login" => "login#index"
  match "login/logon" => "login#logon"
  match "login/logout" => "login#logout"
  match 'login/edit' => "login#edit"
  match "menu" => "menu#index"
  match "tantosyabetugamenmasuta/update_gamen" => "tantosyabetugamenmasuta#update_gamen"
  match "menumasuta/exportcsv" => "menumasuta#exportcsv"
  #match ':controller(/:action(/:id(.:format)))'
  match "menumasuta/exportall" => "menumasuta#exportall"
  #match "mb005" => "tantosyabetugamenmasuta"

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'
  root :to => "login#index"
  
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
