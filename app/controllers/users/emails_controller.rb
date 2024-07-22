module Users
  class EmailsController < ActionController::Base
    def show
      token = params[:token]
      user = User.confirm_email_by_token(token)

      message = user.errors.blank? ? I18n.t("shieldify.controllers.emails.confirmation.success_messages") : user.errors.full_messages.last
      status = user.errors.blank? ? 'success' : 'error'

      set_cookie('shfy_message', message)
      set_cookie('shfy_status', status)

      redirect_to(Shieldify::Configuration.before_confirmation_url, allow_other_host: true)
    end

    private

    def set_cookie(name, value)
      response.set_cookie(name, { value: value, expires: 1.hour.from_now })
    end
  end
end
