module Shieldify
  module Models
    module EmailAuthenticatable
      module EmailConfirmable
        extend ActiveSupport::Concern

        included do
          before_save :generate_email_confirmation, if: :email_changed?
          after_save :send_email_confirmation_instructions, if: :email_changed?

          validates :unconfirmed_email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: unconfirmed_email_present_and_changed?
          validate :email_and_unconfirmed_email_must_be_different
        end

        class_methods do
          def confirm_email_by_token(token)
            user = find_by_email_confirmation_token(token)

            if user.nil?
              errors.add(:confirmation_token, "not valid")

              return user
            end

            if user.email_confirmation_token_expired?
              resend_email_confirmation_instructions
              errors.add(:confirmation_token, 'has expired')

              return user
            end

            user.confirm_email
            user
          end
        end

        def send_email_confirmation_instructions(**files)
          params = {user: self, action: :email_confirmation_instructions}.merge(files)
          Shieldify::Mailer.base_mailer(params).deliver_later
        end

        def resend_email_confirmation_instructions
          if unconfirmed_email.present? && email_confirmation_token.present?
            generate_email_confirmation_token

            save
          end

          send_email_confirmation_instructions
        end

        def confirm_email
          return false if unconfirmed_email?

          self.email = unconfirmed_email
          self.unconfirmed_email = nil
          self.email_confirmation_token = nil
          self.email_confirmation_sent_at = nil

          save
        end

        private

        def unconfirmed_email_present_and_changed?
          unconfirmed_email.present? && unconfirmed_email_changed?
        end

        def generate_email_confirmation
          self.unconfirmed_email = email
          self.email = nil

          generate_email_confirmation_token
        end

        def generate_email_confirmation_token
          self.email_confirmation_token = SecureRandom.hex(10)
          self.email_confirmation_generated_at = Time.current
        end

        def email_and_unconfirmed_email_must_be_different
          if email.present? && unconfirmed_email.present? && email == unconfirmed_email
            errors.add(:email, "has already been validated.")
          end
        end
      end
    end
  end
end