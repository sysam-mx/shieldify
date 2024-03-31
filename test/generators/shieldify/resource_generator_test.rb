require "test_helper"

class ResourceGeneratorTest < Rails::Generators::TestCase
  tests Shieldify::ResourceGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  setup :prepare_destination

  test "generator runs without errors" do
    assert_nothing_raised do
      run_generator %w(User)
    end
  end

  test "creates a migration file" do
    run_generator %w(User)
    assert_migration "db/migrate/shieldify_create_users.rb"
  end

  test "migration file content" do
    run_generator %w(User)
    assert_migration "db/migrate/shieldify_create_users.rb" do |migration|
      assert_match /class ShieldifyCreateUsers/, migration
      assert_match /create_table :users/, migration
      # agregar más aserciones para verificar el contenido específico de la migración
    end
  end

  test "creates a model file" do
    run_generator %w(User)
    assert_file "app/models/user.rb"
  end

  test "model file content" do
    run_generator %w(User)
    assert_file "app/models/user.rb"
  end

  test "injects method into the model" do
    run_generator %w(User)
    assert_file "app/models/user.rb", /shieldify :email_authenticatable, :registerable/
  end
end