require 'warden'

module Warden
  module Strategies
    class Email < Warden::Strategies::Base
      def valid?        
        request.path.include?("shfy/login") && params['email'] && params['password']
      end

      def authenticate!
        user = User.authenticate_by_email(email: request.params['email'], password: request.params['password'])
        return fail!("Unauthorized: #{user.errors.full_messages.join(", ")}") unless user.errors.empty?

        handle_user_authentication(user)
      end

      private

      def handle_user_authentication(user)
        JwtService.encode(user.id) do |success, token, jti, error|
          if success
            process_jwt_token(user, token, jti)
          else
            fail!("JWT token generation failed: #{error}")
          end
        end
      end

      def process_jwt_token(user, token, jti)
        jwt_token = user.jwt_sessions.create(jti: jti)
        if jwt_token.persisted?
          set_authorization_header(token)
          success!(user)
        else
          fail!("Failed to save JWT token: #{jwt_token.errors.full_messages.join(", ")}")
        end
      end

      def set_authorization_header(token)
        env['response_headers'] ||= {}
        env['response_headers']['Authorization'] = "Bearer #{token}"
      end
    end
  end
end
