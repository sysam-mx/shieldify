module Shieldify
  module Controllers
    module Helpers
      def current_user
        warden.user
      end

      def user_signed_in?
        !!current_user
      end

      def authenticate_user!
        unless user_signed_in?
          respond_to_unauthorized
        end
      end

      private

      def warden
        request.env['warden']
      end

      def respond_to_unauthorized
        render json: { error: 'No autorizado' }, status: :unauthorized
      end
    end
  end
end
