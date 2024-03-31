module Users
  module Emails
    class ResetPasswordsController < ApplicationController
      # POST /users/email/reset_password
      def create
        user = User.find_by(email: params[:email])

        if user.present?
          # Aquí se asume la existencia de un método que genera un token de restablecimiento
          # de contraseña y envía un correo electrónico al usuario con instrucciones.
          user.send_reset_email_password_instructions
          render json: { message: 'Se ha enviado un correo con instrucciones para restablecer tu contraseña.' }, status: :ok
        else
          render json: { error: 'No se encontró un usuario con ese correo electrónico.' }, status: :not_found
        end
      end

      # PUT /users/email/:token/reset_password
      def update
        user = User.find_by(reset_email_password_token: params[:token])

        if user.present? && user.reset_password(params[:password], params[:password_confirmation])
          render json: { message: 'Tu contraseña ha sido restablecida exitosamente.' }, status: :ok
        else
          render json: { error: 'El token no es válido o las contraseñas no coinciden.' }, status: :unprocessable_entity
        end
      end
    end
  end
end