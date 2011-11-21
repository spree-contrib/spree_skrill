Rails.application.routes.draw do
  resources :orders do
    resource :checkout, :controller => 'checkout' do
      member do
        get :skrill_cancel
        get :skrill_success
      end
    end
  end

  match '/skrill' => 'skrill_status#update', :via => :post, :as => :skrill_status_update

end
