module Shieldify
  class Railtie < ::Rails::Railtie
    initializer 'shieldify.add_routes' do |app|
      app.routes.prepend do
        get 'shfy/users/email/:token/confirm', to: 'users/emails#show', as: :users_email_confirmation
        # post 'shfy/users/email/reset_password', to: 'users/emails/reset_passwords#create'
        # put 'shfy/users/email/:token/reset_password', to: 'users/emails/reset_passwords#update'
        # get 'shfy/users/access/:token/unlock', to: 'users/access#show'
      end
    end

    initializer 'shieldify.configure_warden' do |app|
      app.middleware.use Warden::Manager do |manager|
        manager.strategies.add(:email, Shieldify::Strategies::Email)
        manager.strategies.add(:jwt, Shieldify::Strategies::Jwt)

        manager.default_strategies :email, :jwt

        manager.default_strategies :email
        manager.scope_defaults :default, store: false
        manager.failure_app = ->(env) { Shieldify::FailureApp.call(env) }
      end
    end

    initializer 'shieldify.insert_middleware', after: :load_config_initializers do |app|
      app.middleware.insert_after Warden::Manager, Shieldify::Middleware
    end

    initializer 'shieldify.require' do
      require_relative '../../app/models/jwt_session'
      require_relative '../../app/controllers/users/emails_controller'
    end

    initializer 'shieldify.active_record' do
      ActiveSupport.on_load(:active_record) do
        include Shieldify::ModelExtensions
      end
    end

    initializer 'shieldify.action_mailer' do |app|
      ActiveSupport.on_load(:action_mailer) do
        include app.routes.url_helpers
      end
    end

    initializer 'shieldify.include_controller_helpers' do
      ActiveSupport.on_load(:action_controller_api) do
        include Shieldify::Controllers::Helpers
      end
    end
  end
end
