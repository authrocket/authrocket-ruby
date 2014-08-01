module AuthRocket
  class Railtie < Rails::Railtie

    initializer "authrocket.log_runtime" do |app|
      require 'authrocket/api/log_subscriber'
      ActiveSupport.on_load(:action_controller) do
        include NCore::ControllerRuntime
        register_api_runtime AuthRocket::LogSubscriber, 'AuthRocket'
      end
    end

  end
end
