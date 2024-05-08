require 'warden'

module Warden
  module Strategies
    class Email < Warden::Strategies::Base
      def valid?
        request.path.include?("shfy/login") && params['email'] && params['password']
      end

      def authenticate!
        user = User.authenticate(email: params['email'], password: params['password'])

        if user.errors.empty?
          # Agregar el token al header de la respuesta
          token = user.generate_jwt
          env['response_headers'] ||= {}
          env['response_headers']['Authorization'] = "Bearer #{token}"

          success!(user)
        else
          fail!("Unauthorized: #{user.errors.full_messages.last}")
        end
      end
    end
  end
end
