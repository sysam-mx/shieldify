module Shieldify
  class Middleware
    attr_reader :app

    def initialize(app)
      @app = app
    end

    def call(env)
      env['warden'].authenticate!

      status, headers, response = app.call(env)
      headers = headers_with_token(env, headers)
      [status, headers, response]
    end

    private

    def headers_with_token(env, headers)
      token = env["auth.jwt"]
      headers['Authorization'] = "Bearer #{token}"
      headers
    end
  end
end
