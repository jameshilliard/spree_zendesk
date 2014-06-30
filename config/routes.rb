Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :zendesk
  end
  constraints(Spree::Zendesk) do
    get '/(*path)', :to => 'zendesk#login', :as => 'zendesk'
  end
end
