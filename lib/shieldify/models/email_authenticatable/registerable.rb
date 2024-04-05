# frozen_string_literal: true

module Shieldify
  module Models
    module EmailAuthenticatable
      module Registerable
        extend ActiveSupport::Concern

        included do
          before_validation :normalize_email

          # Email validations
          validates :email, presence: true, if: -> { password.present? || email_changed? }
          validates :email, format: { with: Shieldify::Configuration.email_regexp }, if: -> { email.present? }
          validates :email, uniqueness: true, if: -> { email.present? }

          # Password extra validations
          validates :password, presence: true, if: -> { email.present? && new_record? }
          validate :password_complexity, if: -> { password.present? }
          validates :password, length: { minimum: 8 }, if: -> { password.present? }
        end

        class_methods do
          def register(email:, password:, password_confirmation:)
            user = new(email: email, password: password, password_confirmation: password_confirmation)
            user.save
            user
          end
        end

        def update_password(current_password:, new_password:, password_confirmation:)
          if authenticate(current_password)
            update(password: new_password, password_confirmation: password_confirmation)

            # send_password_changed_notification if Shieldify::Configuration.send_password_changed_notification
          else
            errors.add(:password, "is invalid")
          end
        
          self
        end

        def update_email(current_password:, new_email:)
          if authenticate(current_password)
            update(email: new_email)

            # send_email_change_notification if Shieldify::Configuration.send_email_changed_notification
          else
            errors.add(:password, "is invalid")
          end
        
          self
        end

        private

        def normalize_email
          self.email = email.downcase.strip if email.present?
        end

        def password_complexity
          return if password.blank?
          regex = Shieldify::Configuration.password_complexity
      
          unless password.match(regex)
            errors.add :password, 'debe incluir al menos una letra mayúscula, una letra minúscula, un número y un carácter especial (@$!%*?&)'
          end
        end
      end
    end
  end
end