class LoginsController < AuthRocket::ArController

  def login
    super
    if current_session
      redirect_to @redir || AuthRocket::Api.default_login_path
    end
  end

  def logout
    super
    redirect_to '/', notice: 'You have been logged out.'
  end

end
