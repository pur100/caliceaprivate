Rails.application.routes.draw do
  root to: 'pages#index'
  post 'checkout_pro', to: "pages#checkout_pro"
  post 'delete_all_orders', to: "pages#delete_all_orders"
  post 'create_pro_customer', to: "pages#create_pro_customer"
  post 'edit_pro', to: "pages#edit_pro"

end

