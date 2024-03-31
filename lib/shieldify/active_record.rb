# frozen_string_literal: true

require "orm_adapter"
require 'orm_adapter/adapters/active_record'
require "shieldify/model_extensions"

ActiveSupport.on_load(:active_record) do
  include Shieldify::ModelExtensions
end