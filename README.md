# AuthRocket

[AuthRocket](https://authrocket.com/) provides Auth as a Service, making it quick and easy to add signups, logins, social auth, a full user management UI, and much more to your app.

This gem works with both Rails and plain Ruby. It will auto-detect Rails and enable Rails-specific features as appropriate.



## Usage - Rails

AuthRocket includes a streamlined Rails integration that automatically provides login and logout actions, and all relevant handling. For a new app, we highly recommend this.

Note: The streamlined integration requires Rails 4.2+.

To your Gemfile, add:

    gem 'authrocket', require: 'authrocket/rails'

Then ensure the following environment variables are set:

    AUTHROCKET_LOGIN_URL  = https://sample.e1.loginrocket.com/
    AUTHROCKET_JWT_SECRET = jsk_SAMPLE

If you plan to access the AuthRocket API as well, you'll need these variables too:

    AUTHROCKET_API_KEY    = ko_SAMPLE
    AUTHROCKET_URL        = https://api-e1.authrocket.com/v1
    AUTHROCKET_REALM      = rl_SAMPLE   # optional
    
Finally, add a `before_action` command to any/all controllers or actions that should require a login.

For example, to protect your entire app:

    class ApplicationController < ActionController::Base
      before_action :require_valid_token
    end

Selectively exempt certain actions or controllers using the standard `skip_before_action` method:

    class ContactUsController < ActionController::Base
      skip_before_action :require_valid_token, only: [:new, :create]
    end

Helpers are provided to create login, signup, and logout links:

    <%= link_to 'Login', ar_login_url %>
    <%= link_to 'Signup', ar_signup_url %>
    <%= link_to 'Logout', logout_path %>

Both the current session and user are available to your controllers and views:

    current_session # => AuthRocket::Session
    current_user    # => AuthRocket::User

Membership and Org data is accessible through those helpers as well. Be sure to tell AuthRocket to include Membership and/or Org data in the JWT (Realm -> Settings -> Sessions & JWT).

    current_user.memberships
    current_user.memberships.first.org
    current_user.orgs

See below for customization details.



## Usage - everywhere else

If you aren't using Rails, or if the streamlined integration above is too opinionated, use the gem without the extra Rails integration.

In your Gemfile, add:

    gem 'authrocket'

Then set the following environment variables:

    # If accessing the AuthRocket API:
    AUTHROCKET_API_KEY    = ko_SAMPLE
    AUTHROCKET_URL        = https://api-e1.authrocket.com/v1 # must match your account's provisioned cluster
    AUTHROCKET_REALM      = rl_SAMPLE   # optional
    #
    # If using JWT-verification of AuthRocket's login tokens:
    AUTHROCKET_JWT_SECRET = jsk_SAMPLE

If you're using either Hosted LoginRocket or authrocket.js to manage logins, see Verifing login tokens below. If you plan to use the API to directly authenticate, see the [API docs](https://authrocket.com/docs/api).



## Configuration

By default, AuthRocket automatically loads credentials from environment variables. This is optimal for any 12-factor deployment. Supported variables are:

`AUTHROCKET_API_KEY = ko_SAMPLE`
Your AuthRocket API key. Required to use the API (but not if only performing JWT verification of login tokens).

`AUTHROCKET_JWT_SECRET = jsk_SAMPLE`
Used to perform JWT signing verification of login tokens. Not required if validating all tokens using the API instead. This is a realm-specific value, so like `AUTHROCKET_REALM`, set it on a per-use basis if using multiple realms.

`AUTHROCKET_LOGIN_URL = https://sample.e1.loginrocket.com/`
The LoginRocket URL for your Connected App. Only used by the streamlined Rails integration (for redirects), but still available to use otherwise. If your app uses multiple realms, you'll need to handle this on your own. If you're using a custom domain, this will be that domain and will not contain 'loginrocket.com'.

`AUTHROCKET_REALM = rl_SAMPLE`
Sets an application-wide default realm ID. If you're using a single realm, this is definitely easiest. Certain multi-tenant apps might using multiple realms. In this case, don't set this globally, but include it as part of the `:credentials` set for each API method.

`AUTHROCKET_URL = https://api-e1.authrocket.com/v1`
The URL of the AuthRocket API server. This may vary depending on which cluster your account is provisioned on.


It's also possible to configure AuthRocket using a Rails initializer (or other initialization code). 

    AuthRocket::Api.credentials = {
      api_key: 'ko_SAMPLE',
      jwt_secret: 'jsk_SAMPLE',
      loginrocket_url: 'https://sample.e1.loginrocket.com/',
      realm: 'rl_SAMPLE',
      url: 'https://api-e1.authrocket.com/v1'
    }



## Customizing the Rails integration

The built-in Rails integration tries to handle as much for you as possible. However, there may be times when you wish to modify the default behavior.


#### The default post-login path

After a user logs in (or signs up), they are returned to either the last page they tried to access (if known) or to `'/'` (the default path).

This default path may be changed using an initializer.

Create/edit `config/initializers/authrocket.rb` and add:

```ruby
AuthRocket::Api.default_login_path = '/manage'
```


#### /login and /logout routes

The default routes for login and logout are `/login` and `/logout`, respectively. To override them, add an initializer for AuthRocket (eg: `config/initializers/authrocket.rb`) and add:

    AuthRocket::Api.use_default_routes = false

Then add your own routes to `config/routes.rb`:

    get 'mylogin' => 'logins#login'
    get 'mylogout' => 'logins#logout'


#### The login controller

AuthRocket's default login controller automatically sets up the session (by storing the login token in `session[:ar_token]`) and makes a best effort at returning the user to where they were when the login request was triggered.

If you require more customization than provided by modifying the default post-login path, as outlined above, you may create your own LoginsController and inherit from AuthRocket's controller:

    class LoginsController < AuthRocket::ArController
      def login
        super
        if current_session
          # @redir will be present if the user's previous URL was able to be
          # saved. If not, then provide a fallback (eg: root_path,
          # manager_path, etc).
          redirect_to @redir || dashboard_path
        end
        # else if login failed, a redirect to LoginRocket happens automatically
      end

      def logout
        super
        # Change the path and/or the message.
        redirect_to root_path, notice: 'You have been logged out.'
      end
    end

If you wish to replace all of the login logic, create a new, different controller that doesn't inherit from `AuthRocket::ArController` (and also override the routes, as per above). You may wish to look at `ArController` as a reference.



## Verifying login tokens

If you're not using the streamlined Rails integration, you'll need to verify the login tokens (unless you're using the API to authenticate directly).


#### JWT verification

AuthRocket's login tokens use the JWT standard and are cryptographically signed. Verifying the signature is extremely fast. Here's are a couple examples of using this:

    def current_user
      @_current_user ||= AuthRocket::Session.from_token(session[:ar_token]).try(:user)
    end

`from_token` returns `nil` if the token is missing, expired, or otherwise invalid.


#### API verification

AuthRocket also supports Managed Sessions, which enables you to enforce logouts, even across apps (single sign-out!). In this instance, the session is regularly verified using the AuthRocket API.

    def current_user
      @_current_user ||= AuthRocket::Session.retrieve(session[:ar_token]).try(:user)
    end

For better performance (and to avoid API rate limits), you may want to cache the results of the API call for 3-15 minutes.


#### Initial login

Each of the above are designed for ongoing use. The initial login isn't going to be much different though. Here's an example login action:

    def login
      if params[:token]
        if AuthRocket::Session.from_token(params[:token])
          session[:ar_token] = params[:token]
          redirect_to '/'
          return
        end
      end
      redirect_to AuthRocket::Api.credentials[:loginrocket_url]
    end



## Reference

For full details on the AuthRocket API, including examples for Ruby, see our [documentation](https://authrocket.com/docs).



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request



## License

MIT
