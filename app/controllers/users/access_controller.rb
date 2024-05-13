module Users
  class AccessController < ActionController::Base
    # GET /users/access/:token/unlock
    def show
      user = User.find_by(unlock_token: params[:token])

      if user.present? && user.unlock_access
        # Asume que `unlock_access` es un método en tu modelo User que realiza la lógica necesaria
        # para desbloquear el acceso del usuario y limpiar el token de desbloqueo.
        render json: { message: 'Tu cuenta ha sido desbloqueada exitosamente. Ahora puedes iniciar sesión.' }, status: :ok
      else
        render json: { error: 'El token proporcionado no es válido o ya ha sido utilizado.' }, status: :not_found
      end
    end
  end
end