module AuthRocket
  class Engine < ::Rails::Engine

    initializer "authrocket.helpers" do
      require_relative 'controller_helper'

      ActiveSupport.on_load(:action_controller) do
        include AuthRocket::ControllerHelper
      end
    end

  end
end
