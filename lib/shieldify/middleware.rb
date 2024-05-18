module Shieldify
  class Middleware
    attr_reader :app, :request

    def initialize(app)
      @app = app
    end

    def call(env)
      @request = Rack::Request.new(env)

      if should_authenticate?
        builder = Rack::Builder.new
        builder.use(Shieldify::Middleware::Authentication)
        builder.run(app)
        builder.call(env)
      else
        app.call(env)
      end
    end

    private

    def should_authenticate?
      should_authenticate_by_email? || should_authenticate_by_jwt?
    end

    def should_authenticate_by_email?
      request.path.end_with?('/shfy/login')
    end

    def should_authenticate_by_jwt?
      request.env['HTTP_AUTHORIZATION'].present?
    end
  end
end
