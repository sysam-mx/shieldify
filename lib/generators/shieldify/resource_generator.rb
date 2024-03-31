module Shieldify
  class ResourceGenerator < Rails::Generators::NamedBase
    include Rails::Generators::Migration
    
    source_root File.expand_path("templates", __dir__)

    def generate_migration
      migration_template 'migration.rb', File.join("db", "migrate", "shieldify_create_#{table_name}.rb"), migration_version: migration_version
    end

    def generate_model
      template 'model.rb', File.join("app", "models", "#{file_name}.rb")
    end

    def inject_method
      inject_into_class File.join("app", "models", "#{file_name}.rb"), class_name, model_contents
    end

    private

    def model_contents
      <<-CONTENT
  shieldify :email_authenticatable, :registerable
CONTENT
    end

    def migration_version
      "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
    end

    def self.next_migration_number(dirname)
      next_migration_number = current_migration_number(dirname) + 1
      ActiveRecord::Migration.next_migration_number(next_migration_number)
    end
  end
end
