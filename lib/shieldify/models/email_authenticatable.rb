# frozen_string_literal: true

module Shieldify
  module Models
    # This module provides email authentication functionality for users. It includes methods to authenticate
    # users by their email and password, and uses `has_secure_password` for secure password handling.
    #
    # @example Including the module in a User model
    #   class User < ApplicationRecord
    #     include Shieldify::Models::EmailAuthenticatable
    #   end
    #
    # @see .authenticate_by_email
    module EmailAuthenticatable
      extend ActiveSupport::Concern

      included do
        # Adds methods to set and authenticate against a BCrypt password. This mechanism requires you to have a
        # password_digest attribute.
        has_secure_password(validations: false)
      end

      class_methods do
        # Authenticates a user by their email and password.
        #
        # @param email [String] The email of the user.
        # @param password [String] The password of the user.
        # @return [User] The authenticated user if the credentials are correct, or a new user object with errors if not.
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
