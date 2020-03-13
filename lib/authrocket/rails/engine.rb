module AuthRocket
  class Engine < ::Rails::Engine

    initializer "authrocket.helpers" do
      require_relative 'controller_helper'

      ActiveSupport.on_load(:action_controller) do
        if self == ActionController::Base
          include AuthRocket::ControllerHelper
          helper AuthRocket::ControllerHelper
          before_action :process_inbound_token
          before_action :process_authorization_header
        end
      end
    end

  end
end
