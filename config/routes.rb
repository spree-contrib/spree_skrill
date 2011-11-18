Rails.application.routes.draw do
  resources :orders do
    resource :checkout, :controller => 'checkout' do
      member do
        get :skrill_return
      end
    end
  end

  match '/skrill' => 'skrill_status#update', :as => :skrill_status_update

end
