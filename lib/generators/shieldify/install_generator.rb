module Shieldify
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    
    source_root File.expand_path("templates", __dir__)

    def copy_initializer
      template 'initializer.rb', File.join("config", "initializers", "shieldify.rb")
    end

    def generate_migration
      migration_template 'migration.rb', File.join("db", "migrate", "shieldify_create_users.rb"), migration_version: migration_version
    end

    def generate_model
      template 'model.rb', File.join("app", "models", "user.rb")
    end

    def inject_method
      inject_into_class File.join("app", "models", "user.rb"), :User, model_contents
    end

    def copy_mailer_layouts
      directory File.join("mailer_layouts"), File.join("app", "views", "layouts", "shieldify")
    end

    def copy_mailer_views      
      directory File.join("mailer_views"), File.join("app", "views", "shieldify", "mailer")
    end

    def copy_locale_file
      template "locales/en.shieldify.yml", File.join("config", "locales", "en.shieldify.yml")
    end

    private

    def model_contents
      <<-CONTENT
  shieldify email_authenticatable: %i[registerable confirmable]
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
