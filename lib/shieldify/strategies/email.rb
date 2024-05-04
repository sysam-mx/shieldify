require 'warden'

module Warden
  module Strategies
    class Email < Warden::Strategies::Base
      def valid?
        request.path.include?("shfy/login") && params['email'] && params['password']
      end

      def authenticate!
        user = User.authenticate(email: params['email'], password: params['password'])

        if user.present?
          success!(user)
        else
          fail!("Unauthorized: Invalid email or password")
        end
      end
    end
  end
end
