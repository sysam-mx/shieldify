# frozen_string_literal: true

module Shieldify
  module Models
    module EmailAuthenticatable
      extend ActiveSupport::Concern

      included do
        has_secure_password(validations: false)
      end
    end
  end
end