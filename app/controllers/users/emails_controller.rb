module Users
  class EmailsController < ActionController::Base
    def show
      token = params[:token]
      user = User.confirm_email_by_token(token)

      if user.errors.blank?
        render(
          json: { message: I18n.t("shieldify.controllers.emails.confirmation.success_messages") },
          status: :ok
        )
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end