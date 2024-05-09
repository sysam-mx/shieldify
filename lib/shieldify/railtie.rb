require "warden"
require "shieldify/strategies/email.rb"

module Shieldify
  class Railtie < ::Rails::Railtie
    initializer 'shieldify.add_routes' do
      Rails.application.routes.append do
        get   'shfy/users/email/:token/confirm',         to: 'users/emails#show', as: :user_email_confirmation
        post  'shfy/users/email/reset_password',         to: 'users/emails/reset_passwords#create'
        put   'shfy/users/email/:token/reset_password',  to: 'users/emails/reset_passwords#update'
        get   'shfy/users/access/:token/unlock',         to: 'users/access#show'
        
        post '/shfy/login', to: 'sessions#create'
      end
    end

    initializer 'shieldify.configure_warden' do
      Rails.application.config.middleware.use Warden::Manager do |manager|
        manager.default_strategies :email
        manager.scope_defaults :default, store: false
        manager.failure_app = lambda do |env|
          [401, { 'Content-Type' => 'application/json' }, [{ error: 'Unauthorized' }.to_json]]
        end

        manager.strategies.add(:email, Warden::Strategies::Email)
      end
    end
  end
end
