require 'ncore/rails/log_subscriber'

module AuthRocket
  class LogSubscriber < ActiveSupport::LogSubscriber
    include NCore::LogSubscriber
    self.runtime_variable = 'authrocket_runtime'
  end
end

AuthRocket::LogSubscriber.attach_to :authrocket
