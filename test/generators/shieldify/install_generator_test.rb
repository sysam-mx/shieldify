require "test_helper"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests Shieldify::InstallGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  setup :prepare_destination

  test "generator runs without errors" do
    assert_nothing_raised do
      run_generator
    end
  end

  test "creates an initializer file" do
    run_generator
    assert_file "config/initializers/shieldify.rb"
  end

  test "initializer file content" do
    run_generator
    assert_file "config/initializers/shieldify.rb", /Shieldify.setup do |conf|/
    # agregar más aserciones para verificar el contenido específico del  inicializador
  end
end