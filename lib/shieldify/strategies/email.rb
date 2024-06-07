module Shieldify
  module Strategies
    class Email < Warden::Strategies::Base
      def valid?
        json_body['email'].present? && json_body['password'].present?
      end

      def authenticate!
        user = User.authenticate_by_email(email: json_body['email'], password: json_body['password'])
        return fail!("Unauthorized: #{user.errors.full_messages.join(", ")}") unless user.errors.empty?

        handle_user_authentication(user)
      end

      private

      def json_body
        request.body.rewind
        JSON.parse(request.body.read) rescue {}
      end

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
          set_jwt_to_header(token)
          success!(user)
        else
          fail!("Failed to save JWT token: #{jwt_token.errors.full_messages.join(", ")}")
        end
      end

      def set_jwt_to_header(token)
        env['auth.jwt'] ||= {}
        env['auth.jwt'] = token
      end
    end
  end
end
