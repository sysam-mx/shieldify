module Users
  class EmailsController < ActionController::Base
    def show
      token = params[:token]
      user = User.confirm_email_by_token(token)

      if user.errors.blank?
        response.headers['X-Shfy-Message'] = I18n.t("shieldify.controllers.emails.confirmation.success_messages")
        response.headers['X-Shfy-Status'] = 'success'
      else
        response.headers['X-Shfy-Message'] = user.errors.full_messages.last
        response.headers['X-Shfy-Status'] = 'error'
      end

      redirect_to(Shieldify::Configuration.before_confirmation_url, allow_other_host: true)
    end
  end
end