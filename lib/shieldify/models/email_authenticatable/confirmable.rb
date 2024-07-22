# frozen_string_literal: true

module Shieldify
  module Models
    module EmailAuthenticatable
      # This module implements email confirmation using tokens. It generates confirmation tokens
      # when registering or changing a user's email address, enabling confirmation through a secure process.
      # Includes functionality to automatically send confirmation instructions and manage email confirmations.
      # When changing an email, the new one is automatically marked as pending confirmation,
      # requiring the user to verify their access to the new email to complete confirmation.
      # Additionally, it provides methods to check the expiration of confirmation tokens.
      #
      # @example Including the module in a User model
      #   class User < ApplicationRecord
      #     include Shieldify::Models::EmailAuthenticatable::Confirmable
      #   end
      #
      # @see #confirm_email
      # @see #regenerate_and_save_email_confirmation_token
      # @see #send_email_confirmation_instructions
      # @see #email_confirmation_token_expired?
      # @see #pending_email_confirmation?
      # @see #confirmed?
      # @see .confirm_email_by_token
      # @see .resend_email_confirmation_instructions_to
      # @see .add_error_to_empty_user
      module Confirmable
        extend ActiveSupport::Concern

        included do
          # @!attribute [rw] skip_email_confirmation_callbacks
          #   @return [Boolean] Allows selectively skipping email confirmation callbacks.
          attr_accessor :skip_email_confirmation_callbacks

          before_save :generate_email_confirmation, unless: -> { skip_email_confirmation_callbacks? || !email_changed? }
          after_save(
            :send_email_confirmation_instructions,
            unless: -> { skip_email_confirmation_callbacks? || !unconfirmed_email? }
          )
        end

        # Confirms the email if there is a pending email confirmation.
        # This method updates the user's email to the unconfirmed email and clears the confirmation tokens.
        #
        # @return [Boolean] true if the email was successfully confirmed, false otherwise
        def confirm_email
          return false unless pending_email_confirmation?

          self.skip_email_confirmation_callbacks = true

          self.email = unconfirmed_email
          self.unconfirmed_email = nil
          self.email_confirmation_token = nil
          self.email_confirmation_token_generated_at = nil

          save do |result|
            self.skip_email_confirmation_callbacks = nil

            result
          end
        end

        # Regenerates the email confirmation token and saves the user record.
        #
        # @return [Boolean] true if the token was successfully regenerated and saved, false otherwise
        def regenerate_and_save_email_confirmation_token
          generate_email_confirmation_token && save
        end

        # Sends email confirmation instructions to the unconfirmed email.
        #
        # @return [void]
        def send_email_confirmation_instructions
          params = { user: self, email_to: unconfirmed_email, token: email_confirmation_token, action: :email_confirmation_instructions }
          Shieldify::Mailer.with(params).base_mailer.deliver_now
        end

        # Checks if the email confirmation token has expired.
        #
        # @return [Boolean] true if the token has expired, false otherwise
        def email_confirmation_token_expired?
          return true unless email_confirmation_token_generated_at

          email_confirmation_token_generated_at < 24.hours.ago
        end

        # Checks if there is a pending email confirmation.
        #
        # @return [Boolean] true if there is a pending email confirmation, false otherwise
        def pending_email_confirmation?
          unconfirmed_email.present? && email_confirmation_token.present?
        end

        # Checks if the email has been confirmed.
        #
        # @return [Boolean] true if the email is confirmed, false otherwise
        def confirmed?
          email.present?
        end

        def skip_email_confirmation_callbacks?
          @skip_email_confirmation_callbacks
        end

        private

        def generate_email_confirmation
          self.unconfirmed_email = email
          self.email = email_was

          generate_email_confirmation_token
        end

        def generate_email_confirmation_token
          self.email_confirmation_token = SecureRandom.hex(16)
          self.email_confirmation_token_generated_at = Time.current
        end

        class_methods do
          def confirm_email_by_token(token)
            user = find_by_email_confirmation_token(token)

            return add_error_to_empty_user(:email_confirmation_token, :invalid) if user.blank?

            if user.email_confirmation_token_expired?
              user.errors.add(:email_confirmation_token, :expired)

              return user
            end

            user.confirm_email
            user
          end

          def resend_email_confirmation_instructions_to(email)
            user = find_by_unconfirmed_email(email)

            return add_error_to_empty_user(:unconfirmed_email, :not_found) if user.nil?

            user.regenerate_and_save_email_confirmation_token
            user
          end

          def add_error_to_empty_user(param, error)
            user = new
            user.errors.add(param, error)
            user
          end
        end
      end
    end
  end
end
