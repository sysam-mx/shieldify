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
            message = I18n.t("shieldify.controllers.emails.reset_passwords.update.success")
            render json: { message: message }, status: :ok
          else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
          end
        else
          message = I18n.t("shieldify.controllers.emails.reset_passwords.update.failure")
          render json: { error: message }, status: :unprocessable_entity
        end
      end
    end
  end
end

