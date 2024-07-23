module Users
  module Emails
    class ResetPasswordsController < ActionController::API
      # Action to request a password reset
      def create
        user = User.find_by(email: params[:email])
        message = I18n.t("shieldify.controllers.emails.reset_passwords.create.success")

        user.send_reset_email_password_instructions if user

        render json: { message: message }, status: :ok
      end

      # Action to update the password
      def update
        user = User.find_by_reset_email_password_token(params[:token])
        
        if user
          if user.reset_password(new_password: params[:password], new_password_confirmation: params[:password_confirmation])
            set_cookie('shfy_message', I18n.t("shieldify.controllers.emails.reset_passwords.update.success"))
            set_cookie('shfy_status', 'success')
          else
            set_cookie('shfy_message', user.errors.full_messages.last)
            set_cookie('shfy_status', 'error')
          end
        else
          set_cookie('shfy_message', I18n.t("shieldify.controllers.emails.reset_passwords.update.failure"))
          set_cookie('shfy_status', 'error')
        end

        redirect_to(Shieldify::Configuration.after_reset_password_url, allow_other_host: true)
      end

      private

      # Set a cookie with a specified name and value
      def set_cookie(name, value)
        response.set_cookie(name, { value: value, expires: 1.minute.from_now, path: '/' })
      end
    end
  end
end

