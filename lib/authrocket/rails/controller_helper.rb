module AuthRocket::ControllerHelper
  extend ActiveSupport::Concern

  private

  def process_inbound_token
    # if GET (the only method LR uses), redirect to remove ?token=
    if request.get? && conditional_login
      redirect_to safe_this_uri
    end
  end

  def require_login
    unless current_session
      redirect_to ar_login_url(redirect_uri: safe_this_uri)
    end
  end


  def current_session
    @_current_session ||= AuthRocket::Session.from_token(session[:ar_token])
  end

  def current_user
    current_session&.user
  end

  def current_membership
    # LR always sends a JWT with exactly one membership/org
    # other API generated JWTs may vary
    return unless current_user
    current_user.memberships.each{|m| return m if m.selected }.first
  end

  def current_org
    current_membership&.org
  end


  def ar_account_url(**params)
    if id = params.delete(:id) || current_org&.id
      loginrocket_url(path: "/accounts/#{id}", **params)
    else
      ar_accounts_url(**params)
    end
  end

  # force - if false/nil, does not add ?force; else does add it
  def ar_accounts_url(**params)
    if params[:force] || !params.key?(:force)
      params[:force] = nil
    else
      params.delete(:force)
    end
    loginrocket_url(path: '/accounts', **params)
  end

  def ar_login_url(**params)
    loginrocket_url(path: '/login', **params)
  end

  def ar_logout_url(**params)
    params[:session] = current_session.id if current_session
    loginrocket_url(path: '/logout', **params)
  end

  def ar_profile_url(**params)
    loginrocket_url(path: '/profile', **params)
  end

  def ar_signup_url(**params)
    loginrocket_url(path: '/signup', **params)
  end

  def loginrocket_url(path: nil, **params)
    raise "Missing env LOGINROCKET_URL or credentials[:loginrocket_url]" if AuthRocket::Api.credentials[:loginrocket_url].blank?
    uri = Addressable::URI.parse AuthRocket::Api.credentials[:loginrocket_url]
    uri.path = path if path
    uri.path = '/' if uri.path.blank?
    uri.query_values = (uri.query_values||{}).merge(params).stringify_keys if params.present?
    uri.to_s
  end


  # returns: bool -- whether session was updated/replaced
  def conditional_login
    return unless params[:token]
    if s = AuthRocket::Session.from_token(params[:token])
      @_current_session = s
      session[:ar_token] = params[:token]
      true
    end
  end

  def safe_this_uri
    full_url_for(request.get? ? params.to_unsafe_h.except(:account, :session, :token) : {})
  end

end
