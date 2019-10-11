Rails.application.routes.draw do

  if AuthRocket::Api.use_default_routes
    get 'logout' => 'logins#logout'
  end

end
