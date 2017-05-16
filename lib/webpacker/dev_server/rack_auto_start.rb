class Webpacker::DevServer::RackAutoStart
  def initialize(app)
    @app = app
  end

  def call(env)
    Webpacker::DevServer.start if should_start?(env)
    @app.call(env)
  end

  private
    def should_start?(env)
      request = ActionDispatch::Request.new(env)
      request.get? && request.format.try(:html?)
    end
end
