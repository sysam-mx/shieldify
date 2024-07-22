# frozen_string_literal: true

module Shieldify
  module Models
    module EmailAuthenticatable
      # This module provides registration functionality for users, including email normalization,
      # validation of email and password, and methods for registering a user and updating their
      # email and password.
      #
      # @example Including the module in a User model
      #   class User < ApplicationRecord
      #     include Shieldify::Models::EmailAuthenticatable::Registerable
      #   end
      #
      # @see .register
      # @see #update_password
      # @see #update_email
      # @see #send_email_changed_notification
      # @see #send_password_changed_notification
      module Registerable
        extend ActiveSupport::Concern

        included do
          before_validation :normalize_email

          validates :email, presence: true, if: -> { password.present? && new_record? }
          validates :email, format: { with: Shieldify::Configuration.email_regexp }, if: -> { email.present? }
          validates :email, uniqueness: true, if: -> { email.present? }

          validates :password, presence: true, if: -> { email.present? && new_record? }
          validate :password_complexity, if: -> { password.present? }
          validates :password, length: { minimum: 8 }, if: -> { password.present? }
        end

        class_methods do
          # Registers a new user with the given email and password.
          #
          # @param email [String] The email of the user.
          # @param password [String] The password of the user.
          # @param password_confirmation [String] The password confirmation.
          # @return [User] The newly registered user.
          def register(email:, password:, password_confirmation:)
            user = new(email: email, password: password, password_confirmation: password_confirmation)
            user.save
            user
          end
        end

        # Updates the user's password if the current password is valid.
        #
        # @param current_password [String] The current password of the user.
        # @param new_password [String] The new password.
        # @param password_confirmation [String] The new password confirmation.
        # @return [User] The user with the updated password, or with errors if the update failed.
        def update_password(current_password:, new_password:, password_confirmation:)
          if authenticate(current_password)
            if update(password: new_password, password_confirmation: password_confirmation)
              send_password_changed_notification if should_send_password_changed_notification?
            end
          else
            errors.add(:password, :invalid)
          end
        
          self
        end

        # Updates the user's email if the current password is valid.
        #
        # @param current_password [String] The current password of the user.
        # @param new_email [String] The new email.
        # @return [User] The user with the updated email, or with errors if the update failed.
        def update_email(current_password:, new_email:)
          if authenticate(current_password)
            if update(email: new_email)
              send_email_changed_notification if should_send_email_changed_notification?
            end
          else
            errors.add(:password, :invalid)
          end
        
          self
        end

        private

        def send_email_changed_notification
          Shieldify::Mailer.with(user: self, email_to: email, action: :email_changed).base_mailer.deliver_now
        end

        def send_password_changed_notification
          Shieldify::Mailer.with(user: self, email_to: email, action: :password_changed).base_mailer.deliver_now
        end

        def normalize_email
          self.email = email.downcase.strip if email.present?
        end

        def password_complexity
          return if password.blank?
          regex = Shieldify::Configuration.password_complexity

          unless password.match?(regex)
            errors.add(:password, :password_complexity)
          end
        end

        def should_send_password_changed_notification?
          Shieldify::Configuration.send_password_changed_notification
        end

        def should_send_email_changed_notification?
          Shieldify::Configuration.send_email_changed_notification
        end
      end
    end
  end
end