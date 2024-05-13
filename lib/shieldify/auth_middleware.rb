module Shieldify
  class AuthMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      
      env['warden'].authenticate!
      
      @app.call(env)
    end
  end
end
