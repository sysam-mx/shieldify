module Shieldify
  class Railtie < ::Rails::Railtie
    initializer 'shieldify.add_routes' do
      Rails.application.routes.append do
        get 'users/email/:token/confirm', to: 'users/emails#show', as: :user_email_confirmation
        post 'users/email/reset_password', to: 'users/emails/reset_passwords#create'
        put 'users/email/:token/reset_password', to: 'users/emails/reset_passwords#update'
        get 'users/access/:token/unlock', to: 'users/access#show'
      end
    end
  end
end
