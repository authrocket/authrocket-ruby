module AuthRocket::ControllerHelper
  extend ActiveSupport::Concern

  included do
    if respond_to?(:helper_method)
      helper_method :current_session
      helper_method :current_user
      helper_method :ar_login_url
      helper_method :ar_signup_url
    end
  end


  def require_valid_token
    unless current_session
      session[:last_url] = request.get? ? url_for(params.to_unsafe_h.except(:domain, :host, :port, :prototcol, :subdomain, :token)) : url_for
      redirect_to ar_login_url + "?redir=#{ERB::Util.url_encode(session[:last_url])}"
    end
  end


  def current_session
    @_current_session ||= AuthRocket::Session.from_token(session[:ar_token])
  end

  def current_user
    current_session.try(:user)
  end


  def ar_login_url
    @_login_url = loginrocket_url('login')
  end

  def ar_signup_url
    @_signup_url = loginrocket_url('signup')
  end

  def loginrocket_url(path=nil)
    raise "Missing env LOGINROCKET_URL or credentials[:loginrocket_url]" if AuthRocket::Api.credentials[:loginrocket_url].blank?
    s = AuthRocket::Api.credentials[:loginrocket_url].dup
    s.concat('/') unless s.ends_with?('/')
    s.concat(path) if path
    s.freeze
  end

end
