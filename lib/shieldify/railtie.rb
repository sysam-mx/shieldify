require "warden"

module Shieldify
  class Railtie < ::Rails::Railtie
    initializer 'shieldify.add_routes' do |app|
      app.routes.prepend do
        get 'shfy/users/email/:token/confirm', to: 'users/emails#show', as: :users_email_confirmation
        post 'shfy/users/email/reset_password', to: 'users/emails/reset_passwords#create'
        put 'shfy/users/email/:token/reset_password', to: 'users/emails/reset_passwords#update'
        get 'shfy/users/access/:token/unlock', to: 'users/access#show'
        
        post '/shfy/login', to: 'sessions#create' # just for testing
      end
    end

    initializer 'shieldify.action_mailer' do
      ActiveSupport.on_load(:action_mailer) do
        include Rails.application.routes.url_helpers
      end
    end

    initializer 'shieldify.configure_warden' do |app|
      app.middleware.use Warden::Manager do |manager|
        manager.strategies.add(:email, Warden::Strategies::Email)

        manager.default_strategies :email
        manager.scope_defaults :default, store: false
        manager.failure_app = lambda do |env|
          [401, { 'Content-Type' => 'application/json' }, [{ error: 'Unauthorized' }.to_json]]
        end
      end
    end

    initializer 'shieldify.insert_middleware', after: :load_config_initializers do |app|
      app.middleware.insert_after Warden::Manager, Shieldify::AuthMiddleware
    end
  end
end
