class AuthRocket::ArController < ::ApplicationController

  before_action :require_login, only: []
    # ensure :require_login is known so it can be skipped
  skip_before_action :require_login
    # in case it's globally applied to ApplicationController


  def logout
    if AuthRocket::Api.post_logout_path
      uri = Addressable::URI.parse full_url_for
      uri.path = AuthRocket::Api.post_logout_path
      redirect_to ar_logout_url(redirect_uri: uri.to_s), allow_other_host: true
    else
      redirect_to ar_logout_url, allow_other_host: true
    end
    # set flash message in the child

    session[:ar_token] = nil
  end

end
