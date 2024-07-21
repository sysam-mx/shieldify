module Users
  module Emails
    class ResetPasswordsController < ActionController::Base
      # Acción para solicitar el restablecimiento de contraseña
      def create
        user = User.find_by(email: params[:email])

        if user
          user.send_reset_email_password_instructions

          response.headers['X-Shfy-Message'] = I18n.t("shieldify.controllers.emails.reset_passwords.create.success")
          response.headers['X-Shfy-Status'] = 'success'
        else
          response.headers['X-Shfy-Message'] = I18n.t("shieldify.controllers.emails.reset_passwords.create.failure")
          response.headers['X-Shfy-Status'] = 'error'
        end

        redirect_to(Shieldify::Configuration.after_request_reset_password_url, allow_other_host: true)
      end

      # Acción para actualizar la contraseña
      def update
        user = User.find_by_reset_email_password_token(params[:token])
        
        if user
          if user.reset_password(new_password: params[:password], new_password_confirmation: params[:password_confirmation])
            response.headers['X-Shfy-Message'] = I18n.t("shieldify.controllers.emails.reset_passwords.update.success")
            response.headers['X-Shfy-Status'] = 'success'
          else
            response.headers['X-Shfy-Message'] = user.errors.full_messages.last
            response.headers['X-Shfy-Status'] = 'error'
          end
        else
          response.headers['X-Shfy-Message'] = I18n.t("shieldify.controllers.emails.reset_passwords.update.failure")
          response.headers['X-Shfy-Status'] = 'error'
        end

        redirect_to(Shieldify::Configuration.after_reset_password_url, allow_other_host: true)
      end
    end
  end
end