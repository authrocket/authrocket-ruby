module AuthRocket
  class Railtie < Rails::Railtie

    config.action_dispatch.rescue_responses.merge!(
      'AuthRocket::RecordInvalid'  => :unprocessable_entity, # 422
      'AuthRocket::RecordNotFound' => :not_found, # 404
    )

    initializer "authrocket.cache_store" do |app|
      AuthRocket::Api.cache_store = Rails.cache
    end

    initializer "authrocket.log_runtime" do |app|
      require 'authrocket/api/log_subscriber'
      ActiveSupport.on_load(:action_controller) do
        include NCore::ControllerRuntime
        register_api_runtime AuthRocket::LogSubscriber, 'AuthRocket'
      end
    end

  end
end
