require 'warden'
require 'jwt'

module Warden
  module Strategies
    class Jwt < Warden::Strategies::Base
      def valid?
        token.present?
      end

      def authenticate!
        user = User.find_by(id: payload['user_id'])
        if user
          success!(user)
        else
          fail!('User not found')
        end
      end

      private

      def token
        @token ||= begin
          token = request.headers['Authorization']
          token.split(' ').last if token
        end
      end

      def payload
        @payload ||= begin
          decoded_token = JWT.decode(token, Rails.application.credentials.jwt_secret, true, algorithm: 'HS256').first if token
          decoded_token.is_a?(Hash) ? decoded_token : {}
        rescue JWT::DecodeError
          {}
        end
      end
    end
  end
end

