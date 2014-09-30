# AuthRocket

[AuthRocket](http://authrocket.com/) provides Auth as a Service, making it quick and easy to add signups, logins, a full user management UI, and much more to your app.

This gem works with both Rails and plain Ruby. It will auto-detect Rails and enable a couple Rails-specific features as appropriate.


## Usage

For installation, add `gem 'authrocket'` to your Gemfile. More details are below.


### Configuration

By default, AuthRocket automatically loads your credentials from environment variables. For such hosting environments, including Heroku, just configure these:

    AUTHROCKET_ACCOUNT = org_SAMPLE
    AUTHROCKET_API_KEY = key_SAMPLE
    AUTHROCKET_URL     = https://api-e1.authrocket.com/v1
    AUTHROCKET_REALM   = rl_SAMPLE   # optional

`AUTHROCKET_URL` must be updated based on what cluster your account is provisioned on.

`AUTHROCKET_REALM` is optional. If you're using a single Realm, it's easiest to add it here as an application-wide default. If you're using multiple Realms with your app, we recommend leaving it out here and setting it as you go.

It's possible to configure AuthRocket using a Rails initializer (or other initializaiton code) too.

    AuthRocket::Api.credentials = {
      account: 'org_SAMPLE',
      api_key: 'key_SAMPLE',
      url: 'https://api-e1.authrocket.com/v1',
      realm: 'rl_SAMPLE'
    }


### Hosted Logins

AuthRocket has a few options to handle logins. One option is to let AuthRocket handle the login process completely, which is what's shown here. Your app only needs to verify the final login token. This example is specific to Rails, but adapt accordingly for Sinatra or any other framework.

To get started, login to AuthRocket and add a Login Policy (under Logins/Signups) for your chosen Realm (create your first Realm if you haven't already). 

Be sure to enable Hosted Logins (a separate step) and specify a Login Handler URL. For development purposes, we'll point the Login Handler URL to your local app. Assuming your Rails app is running on port 3000, you'd enter `http://localhost:3000/login`.

After enabling Hosted Logins, take note of the LoginRocket URL. You'll need this below.

Let's add a couple methods to your Application Controller, substituting the correct value for `LOGIN_URL`:

    class ApplicationController < ActionController::Base
      before_filter :require_user
      # This protects *all* of your app. If that's not what
      #   you want, then just add this to the controllers
      #   that need to be protected.

      private

      LOGIN_URL = 'https://sample.e1.loginrocket.com/'
      # This should be your app's own LoginRocket URL, as
      #   shown in the Login Policy details.

      def require_user
        unless session[:ar_user_id]
          flash.keep
          redirect_to LOGIN_URL
        end
      end

      def current_user
        @_current_user ||= session[:ar_user_id] && AuthRocket::User.find(session[:ar_user_id])
      end

      def current_user_name
        session[:name]
      end
    end

Create a Login or Session controller if you don't have one already:

    rails g controller logins

Then add login and logout methods:

    class LoginsController < ApplicationController
      skip_before_filter :require_user

      def login
        flash.keep
        if params[:token]
          if login_rec = AuthRocket::Event.validate_token(params[:token])
            user = login_rec.user
            session[:ar_user_id] = user.id
            session[:name] = user.name
            redirect_to root_path
            return
          end
        end
        require_user
      end

      def logout
        session[:ar_user_id] = nil
        redirect_to root_path, notice: 'You have been logged out.'
      end
    end

Finally, update `config/routes.rb`:

    get '/login' => 'logins#login'
    get '/logout' => 'logins#logout'

That's it. You're all done!


### Other Methods

For full details on the AuthRocket API, including examples for Ruby, see our [documentation](http://authrocket.com/docs).


## Installation

Add this line to your application's Gemfile:

    gem 'authrocket'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install authrocket


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## License

MIT
