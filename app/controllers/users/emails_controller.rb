module Users
  class EmailsController < ApplicationController
    def show
      token = params[:token]
      user = User.confirm_email_by_token(token)

      if user.errors.blank?
        render json: { message: 'Email confirmado exitosamente. Ahora puedes iniciar sesión.' }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end