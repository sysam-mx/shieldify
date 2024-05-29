# frozen_string_literal: true

module Shieldify
  # This module provides extensions for models to include Shieldify functionality.
  # It allows dynamic inclusion of modules and submodules for various authentication features.
  #
  # The primary purpose of this module is to simplify the process of adding authentication
  # capabilities to models in a Rails application. By including this module,
  # developers can easily integrate functionalities such as email-based authentication,
  # user registration, email confirmation, and more, depending on the modules and submodules
  # specified.
  #
  # This module uses ActiveSupport::Concern to extend the including model with class methods
  # and associations necessary for managing JWT sessions and other authentication-related tasks.
  #
  # @example Including the module in a User model
  #   # To use this module, include it in your model (typically a User model).
  #   # Then, use the `shieldify` method to specify the desired modules and submodules.
  #   # In this example, the User model is being extended with email authentication,
  #   # and two submodules: registerable and confirmable.
  #   class User < ApplicationRecord
  #     include Shieldify::ModelExtensions
  #
  #     # The `shieldify` method is called with a hash where the key is the main module
  #     # (:email_authenticatable) and the value is an array of submodules
  #     # (%i[registerable confirmable]).
  #     # This will dynamically include the corresponding modules and submodules
  #     # from the Shieldify::Models namespace into the User model.
  #     shieldify email_authenticatable: %i[registerable confirmable]
  #   end
  #
  # @see Shieldify::ModelExtensions#shieldify
  module ModelExtensions
    extend ActiveSupport::Concern

    class_methods do
      # Dynamically includes modules. Accepts a hash where the keys are symbols
      # of main modules and the values are arrays of submodules to include.
      #
      # @example
      #   shieldify email_authenticatable: %i[registerable confirmable]
      #
      # This method is intended to be used within a user class or any other class
      # that acts as a user.
      #
      # @param modules [Hash<Symbol, Array<Symbol>>] A hash where the keys are main modules and the values are arrays of submodules to include.
      # @return [void]
      def shieldify(modules)
        modules.each do |parent, submodules|
          include_parent_module(parent)

          submodules.each do |submodule|
            include_submodule(parent, submodule)
          end
        end

        has_many :jwt_sessions, dependent: :destroy
      end

      private

      # Includes the parent module based on the provided symbol
      def include_parent_module(parent_module)
        include "Shieldify::Models::#{parent_module.to_s.camelize}".constantize
      end

      # Includes a specific submodule within a parent module
      def include_submodule(parent_module, submodule)
        include "Shieldify::Models::#{parent_module.to_s.camelize}::#{submodule.to_s.camelize}".constantize
      end
    end
  end
end