require "shieldify/models/email_authenticatable"
require "shieldify/models/email_authenticatable/registerable"

module Shieldify
  module ModelExtensions
    extend ActiveSupport::Concern

    included do
      has_many :jwt_sessions, dependent: :destroy
    end

    class_methods do
      # Incluye módulos dinámicamente. Acepta un hash donde las claves son símbolos
      # de módulos principales y los valores son arrays de submódulos para incluir.
      def shieldify(modules)
        modules.each do |parent, submodules|
          include_parent_module(parent)

          submodules.each do |submodule|
            include_submodule(parent, submodule)
          end
        end
      end

      private

      # Incluye el módulo padre basado en el símbolo proporcionado
      def include_parent_module(parent_module)
        include "Shieldify::Models::#{parent_module.to_s.camelize}".constantize
      end

      # Incluye un submódulo específico dentro de un módulo padre
      def include_submodule(parent_module, submodule)
        include "Shieldify::Models::#{parent_module.to_s.camelize}::#{submodule.to_s.camelize}".constantize
      end
    end
  end
end