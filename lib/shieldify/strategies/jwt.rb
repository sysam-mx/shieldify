module Shieldify
  module Strategies
    class Jwt < Warden::Strategies::Base
      def valid?
        request.env['HTTP_AUTHORIZATION'].present?
      end

      def authenticate!
        token = extract_token_from_header
        return fail!("Authorization token not provided") unless token

        JwtService.decode(token) do |success, payload, error|
          if success
            authenticate_with_payload(payload)
          else
            fail!("Invalid token: #{error}")
          end
        end
      end

      private

      def extract_token_from_header
        request.env['HTTP_AUTHORIZATION']&.split(' ')&.last
      end

      def authenticate_with_payload(payload)
        user = find_user(payload['sub'])
        return unless user

        jwt_session = find_jwt_session(user, payload['jti'])
        return unless jwt_session

        if token_expired_halfway?(payload['exp'])
          refresh_token(user, jwt_session)
        else
          success!(user)
        end
      end

      def find_user(user_id)
        user = User.find_by(id: user_id)
        fail!("Invalid token: user not found") unless user
        user
      end

      def find_jwt_session(user, jti)
        jwt_session = user.jwt_sessions.find_by(jti: jti)
        fail!("Invalid token: session not found") unless jwt_session
        jwt_session
      end

      def token_expired_halfway?(exp)
        halfway_time = exp - (exp - Time.now.to_i) / 2
        Time.now.to_i >= halfway_time
      end

      def refresh_token(user, jwt_session)
        JwtService.encode(user.id) do |success, new_token, new_jti, error|
          if success
            jwt_session.update!(jti: new_jti)
            set_jwt_to_header(new_token)
            success!(user)
          else
            fail!("JWT token generation failed: #{error}")
          end
        end
      end

      def set_jwt_to_header(token)
        env['auth.jwt'] ||= {}
        env['auth.jwt'] = token
      end
    end
  end
end


