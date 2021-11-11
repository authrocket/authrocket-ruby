# AuthRocket

[AuthRocket](https://authrocket.com/) provides Auth as a Service, making it quick and easy to add signups, logins, social auth, a full user management UI, and much more to your app.

This gem works with both Rails and plain Ruby. It will auto-detect Rails and enable Rails-specific features as appropriate.



## Usage - Rails

AuthRocket includes a streamlined Rails integration that automatically handles logins and logouts. For a new app, we highly recommend this.

Note: The streamlined integration requires Rails 4.2+.

To your Gemfile, add:

    gem 'authrocket', require: 'authrocket/rails'

Then ensure the following environment variable is set:

    LOGINROCKET_URL    = https://sample.e2.loginrocket.com/

If you've changed the default JWT key type to HS256, you'll also need this variable:

    AUTHROCKET_JWT_KEY = jsk_SAMPLE

If you plan to access the AuthRocket API as well, you'll need these variables too:

    AUTHROCKET_API_KEY = ks_SAMPLE
    AUTHROCKET_URL     = https://api-e2.authrocket.com/v2
    AUTHROCKET_REALM   = rl_SAMPLE   # optional
    
Finally, add a `before_action` command to any/all controllers or actions that should require a login.

For example, to protect your entire app:

    class ApplicationController < ActionController::Base
      before_action :require_login
    end

Selectively exempt certain actions or controllers using the standard `skip_before_action` method:

    class ContactUsController < ApplicationController
      skip_before_action :require_login, only: [:new, :create]
    end

Helpers are provided to create login, signup, and logout links, as well as for users to manage their profile:

    <%= link_to 'Login', ar_login_url %>
    <%= link_to 'Signup', ar_signup_url %>
    <%= link_to 'Logout', logout_path %>
    <%= link_to 'Manage Profile', ar_profile_url %>

Both the current Session and User are available to your controllers and views:

    current_session # => AuthRocket::Session
    current_user    # => AuthRocket::User

The current Membership and Org (account) are accessible through those helpers as well.

    current_membership
    current_org

If a user is a member of more than one org (account), `current_membership` and `current_org` will be reflect the currently selected account. Additional helpers are available to provide appropriate links to your users:

    <%= link_to 'Manage current account', ar_account_url %>
    <%= link_to 'Switch accounts', ar_accounts_url %>

See below for customization details.



## Usage - everywhere else

If you aren't using Rails, or if the streamlined integration above is too opinionated, use the gem without the extra Rails integration.

In your Gemfile, add:

    gem 'authrocket'

Then set the following environment variables:

    # If accessing the AuthRocket API:
    AUTHROCKET_API_KEY = ks_SAMPLE
    AUTHROCKET_URL     = https://api-e2.authrocket.com/v2 # must match your account's provisioned cluster
    AUTHROCKET_REALM   = rl_SAMPLE   # optional
    #
    # If using JWT-verification of AuthRocket's login tokens:
    AUTHROCKET_JWT_KEY = SAMPLE




## Configuration

By default, AuthRocket automatically loads credentials from environment variables. This is optimal for any 12-factor deployment. Supported variables are:

`AUTHROCKET_API_KEY = ks_SAMPLE`
Your AuthRocket API key. Required to use the API (but not if only performing JWT verification of login tokens).

`AUTHROCKET_JWT_KEY = SAMPLE`
Used to perform JWT signing verification of login tokens. Not required if validating all tokens using the API instead. Also not required if LOGINROCKET_URL is set and RS256 keys are being used, as public keys will be auto-retrieved. This is a realm-specific value, so like `AUTHROCKET_REALM`, set it on a per-use basis if using multiple realms.

`AUTHROCKET_REALM = rl_SAMPLE`
Sets an application-wide default realm ID. If you're using a single realm, this is definitely easiest. Certain multi-tenant apps might using multiple realms. In this case, don't set this globally, but include it as part of the `:credentials` set for each API method.

`AUTHROCKET_URL = https://api-e2.authrocket.com/v2`
The URL of the AuthRocket API server. This may vary depending on which cluster your service is provisioned on.

`LOGINROCKET_URL = https://SAMPLE.e2.loginrocket.com/`
The LoginRocket URL for your Connected App. Used by the streamlined Rails integration (for redirects) and for auto-retrieval of RS256 JWT keys (if AUTHROCKET_JWT_KEY is not set). If your app uses multiple realms, you'll need to handle this on your own. If you're using a custom domain, this will be that domain and will not contain 'loginrocket.com'.


It's also possible to configure AuthRocket using a Rails initializer (or other initialization code). 

    AuthRocket::Api.credentials = {
      api_key: 'ks_SAMPLE',
      jwt_key: 'SAMPLE',
      loginrocket_url: 'https://sample.e2.loginrocket.com/',
      realm: 'rl_SAMPLE',
      url: 'https://api-e2.authrocket.com/v2'
    }



## Customizing the Rails integration

The built-in Rails integration tries to handle as much for you as possible. However, there may be times when you wish to modify the default behavior.


#### Logins

The Rails integration handles logins on any path by detecting the presence of `?token=...`. It will process the login and then immediately redirect back to the same path without `?token=`; this helps prevent browsers and bookmarks from accidentally saving or caching the login token.

Likewise, the built-in handler for `before_action :require_login` will automatically redirect to LoginRocket when the user is not currently logged in. `?redirect_uri=<current_path>` will be automatically included so that the user returns to the same place post-login. You can override this behavior by replacing `before_login`.

    # For example, to force the user to always return to "/manage":
    def require_login
      unless current_session
        redirect_to ar_login_url(redirect_uri: "/manage")
      end
    end

AuthRocket will verify the domain + path to redirect to. You can configure this at Realm -> Settings -> Connected Apps -> (edit) -> Login URLs. The first URL listed will be the default, so it should generally be the default "just logged in" path.

Paths are validated as "equal or more specific". That is, if Login URLs contains "https://my.app/manage", then any path starting with "/manage" will be allowed, but "/other" will not be allowed. If you want to allow any path at your domain, add "https://my.app/" (since "/" will match any path).


#### Logouts

##### The default post-logout path

Upon logout, the user will be returned to the root path ("/").

This default path may be changed using an initializer. Create/edit `config/initializers/authrocket.rb` and add:

    AuthRocket::Api.post_logout_path = '/other'


##### /logout route

The default route for logout is `/logout`. To override it, add an initializer for AuthRocket (eg: `config/initializers/authrocket.rb`) and add:

    AuthRocket::Api.use_default_routes = false

Then add your own routes to `config/routes.rb`:

    get 'mylogout' => 'logins#logout'


##### The logout action

AuthRocket's default login controller automatically sets a logout message using `flash`.

You may customize this, or other logout behavior, by creating your own LoginsController and inherit from AuthRocket's controller:

    class LoginsController < AuthRocket::ArController
      def logout
        super
        flash[:notice] = 'You have been logged out.'
      end
    end

If you wish to replace all of the login logic, create a new, different controller that doesn't inherit from `AuthRocket::ArController` (and also override the routes, as per above). You may wish to look at `ArController` as a reference.



## Verifying login tokens

If you're not using the streamlined Rails integration, you'll need to verify the login tokens (unless you're using the API to authenticate directly).


#### JWT verification

AuthRocket's login tokens use the JWT standard and are cryptographically signed. Verifying the signature is extremely fast. Here's are a couple examples of using this:

    def current_user
      @_current_user ||= AuthRocket::Session.from_token(session[:ar_token])&.user
    end

`from_token` returns `nil` if the token is missing, expired, or otherwise invalid.


#### API verification

AuthRocket also supports Managed Sessions, which enables you to enforce logouts, even across apps (single sign-out!). In this instance, the session is regularly verified using the AuthRocket API.

    def current_user
      @_current_user ||= AuthRocket::Session.retrieve(session[:ar_token])&.user
    end

For better performance (and to avoid API rate limits), you will want to cache the results of the API call for 3-15 minutes.


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



## Changing locales

The AuthRocket Core API supports multi-locale access. See the AuthRocket docs for the currently supported locales.

If you are using the streamlined Rails integration alongside LoginRocket, it may not be necessary to set the locale for API access. The locale is primarily used for generating localized error messages. This is only useful for API operations that might generate errors. When handling logins and signups via LoginRocket, LoginRocket will handle all of this for you.

When the Accept-Language header is not sent, the AuthRocket Core API uses English.


#### Global locale

To set a global locale for your app, add this to your AuthRocket initializer:

    AuthRocket::Api.default_headers.merge!(
      accept_language: 'en'
    )


#### Per-request locale

If your app supports multiple locales, then you'll likely want to set the locale on a per-request basis. Add a `headers: {accept_language: 'en'}` param to relevant API calls:

    AuthRocket::User.create(
      email: 'jdoe@example.com',
      password: 'secret!',
      headers: {accept_language: 'en'}
    )



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
