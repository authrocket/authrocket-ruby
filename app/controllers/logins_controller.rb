class LoginsController < AuthRocket::ArController

  def logout
    super
    flash[:notice] = 'You have been logged out.'
  end

end
