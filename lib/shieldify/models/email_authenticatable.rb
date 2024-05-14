# frozen_string_literal: true

module Shieldify
  module Models
    module EmailAuthenticatable
      extend ActiveSupport::Concern

      included do
        has_secure_password(validations: false)
      end

      class_methods do
        def authenticate_by_email(email:, password:)
          user = find_by(email: email)

          return user if user&.authenticate(password)

          user ||= new
          user.errors.add(:email, "invalid email or password")
          user
        end
      end
    end
  end
end
