class AuthRocket::ArController < ::ApplicationController

  before_action :require_valid_token, only: []
    # ensure :require_valid_token is known so it can be skipped
  skip_before_action :require_valid_token
    # in case it's globally applied to ApplicationController

  def login
    if params[:token]
      if s = AuthRocket::Session.from_token(params[:token])
        @_current_session = s
        session[:ar_token] = params[:token]
      end
    end
    if current_session
      @redir = sanitize_redir || session[:last_url]
      session[:last_url] = nil
      # redirect in the child
    else
      require_valid_token
    end
  end

  def logout
    if current_session && current_session.id =~ /^kss_/ && AuthRocket::Api.credentials[:api_key]
      AuthRocket::Session.delete current_session.id
    end
    session[:ar_token] = nil
    # redirect in the child
  end


  private

  # sanitize by making it path-only
  def sanitize_redir(redir=params[:redir])
    return if redir.blank?
    u = defined?(Addressable) ? Addressable::URI.parse(redir) : URI.parse(redir)
    if u
      [u.path, u.query].compact.join('?')
    end
  end

end
