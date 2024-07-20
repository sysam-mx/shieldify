module Shieldify
  module Models
    module EmailAuthenticatable
      module PasswordRecoverable
        extend ActiveSupport::Concern

        included do
          before_save :clear_reset_email_password_token, if: -> { password_digest_changed? }
        end

        class_methods do
          def find_by_reset_email_password_token(token)
            return nil if token.nil?

            find_by(reset_email_password_token: token)
          end
        end

        def generate_reset_email_password_token
          self.reset_email_password_token = SecureRandom.hex(10)
          self.reset_email_password_token_generated_at = Time.current
          save
        end

        def send_reset_email_password_instructions
          generate_reset_email_password_token

          params = {
            user: self,
            email_to: email,
            reset_password_form_url: reset_password_form_url(reset_email_password_token),
            action: :reset_email_password_instructions
          }
          
          Shieldify::Mailer.with(params).base_mailer.deliver_now
        end

        def reset_password(new_password:, new_password_confirmation:)
          if reset_email_password_token_valid?
            if new_password == new_password_confirmation
              self.password = new_password
              clear_reset_email_password_token
              save
            else
              errors.add(:password_confirmation, "doesn't match Password")
              false
            end
          else
            errors.add(:reset_email_password_token, "is invalid or has expired")
            false
          end
        end

        private

        def clear_reset_email_password_token
          self.reset_email_password_token = nil
          self.reset_email_password_token_generated_at = nil
        end

        def reset_email_password_token_valid?
          reset_email_password_token_generated_at && reset_email_password_token_generated_at >= 2.hours.ago
        end

        def reset_password_form_url(token = nil)
          if token.present?
            Shieldify::Configuration.reset_password_form_url + "?token=#{token}"
          else
            Shieldify::Configuration.reset_password_form_url
          end
        end
      end
    end
  end
end

