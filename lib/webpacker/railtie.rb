require "rails/railtie"

require "webpacker/helper"

class Webpacker::Engine < ::Rails::Engine
  initializer :webpacker do |app|
    ActiveSupport.on_load :action_controller do
      ActionController::Base.helper Webpacker::Helper
    end

    ActiveSupport.on_load :action_view do
      include Webpacker::Helper
    end

    Webpacker.bootstrap
    Spring.after_fork { Webpacker.bootstrap } if defined?(Spring)

    if Webpacker.env.development? && Webpacker::DevServer.auto_start?
      Rails.application.config.middleware.use Webpacker::DevServer::RackAutoStart
    end
  end
end
