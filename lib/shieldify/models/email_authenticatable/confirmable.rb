# frozen_string_literal: true

module Shieldify
  module Models
    module EmailAuthenticatable
      # This module implements email confirmation using tokens. It generates confirmation tokens
      # when registering or changing a user's email address, enabling confirmation through a secure process.
      # Includes functionality to automatically send confirmation instructions and manage email confirmations.
      # When changing an email, the new one is automatically marked as pending confirmation,
      # requiring the user to verify their access to the new email to complete confirmation.
      # Additionally, it provides methods to check the expiration of confirmation tokens
      module Confirmable
        extend ActiveSupport::Concern

        included do
          # skip_email_confirmation_callbacks allows selectively skipping
          # the generation of confirmations and the sending of confirmation
          # instructions during the email confirmation process.
          # This solves the issue of unwanted callback activations when
          # confirming an email.
          attr_accessor :skip_email_confirmation_callbacks

          # Callbacks
          before_save :generate_email_confirmation, unless: -> { skip_email_confirmation_callbacks? || !email_changed? }
          after_save(
            :send_email_confirmation_instructions,
            unless: -> { skip_email_confirmation_callbacks? || !unconfirmed_email? }
          )
        end

        def confirm_email
          return false unless pending_email_confirmation?

          self.skip_email_confirmation_callbacks = true

          self.email = unconfirmed_email
          self.unconfirmed_email = nil
          self.email_confirmation_token = nil
          self.email_confirmation_token_generated_at = nil

          save
        end

        def regenerate_and_save_email_confirmation_token
          generate_email_confirmation_token && save
        end

        def send_email_confirmation_instructions
          params = { user: self, token: email_confirmation_token, action: :email_confirmation_instructions }
          Shieldify::Mailer.with(params).base_mailer.deliver_now
        end

        def email_confirmation_token_expired?
          return true unless email_confirmation_token_generated_at

          email_confirmation_token_generated_at < 24.hours.ago
        end

        def pending_email_confirmation?
          unconfirmed_email.present? && email_confirmation_token.present?
        end

        def skip_email_confirmation_callbacks?
          @skip_email_confirmation_callbacks
        end

        def confirmed?
          email.present?
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
              msg = I18n.t('shieldify.models.email_authenticatable.confirmable.email_confirmation_token.errors.expired')
              user.errors.add(:email_confirmation_token, msg)

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

            user.errors.add(
              param.to_sym,
              I18n.t("shieldify.models.email_authenticatable.confirmable.#{param.to_sym}.errors.#{error.to_sym}")
            )

            user
          end
        end
      end
    end
  end
end
