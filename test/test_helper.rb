# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
require "rails/test_help"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [File.expand_path("../test/fixtures", __dir__)]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = File.expand_path("../test/fixtures", __dir__) + "/files"
  ActiveSupport::TestCase.fixtures :all
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  FactoryBot.definition_file_paths << File.expand_path('../test/factories', __dir__)
  FactoryBot.find_definitions
end

# spec minitest
require "minitest/autorun"
require "minitest/spec"
require "minitest/mock"

require "shieldify/models/email_authenticatable/confirmable"
require "shieldify/strategies/email.rb"
require "shieldify/jwt_service"

# For generators
require "generators/shieldify/install_generator"
require "shieldify/mailer"