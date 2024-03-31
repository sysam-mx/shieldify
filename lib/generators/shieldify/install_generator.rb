module Shieldify
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def copy_initializer
      template 'initializer.rb', File.join("config", "initializers", "shieldify.rb")
    end

    def copy_mailer_views      
      directory File.join("mailer_views"), File.join("app", "views", "shieldify", "mailer")
    end

    def copy_mailer_layouts
      directory File.join("mailer_layouts"), File.join("app", "views", "layouts", "shieldify")
    end

    # def generate_mailer_views      
    #   mailers_views.each do |view|
    #     %w(html text).each do |format|
    #       copy_file(
    #         "mailer_views/#{view}.#{format}.erb",
    #         File.join("app", "views", "shieldify", "mailer", "#{view}.#{format}.erb")
    #       )
    #     end
    #   end
    # end

    private

      def mailer_views
        %w(
          confirmation_instructions
          reset_password_instructions
          unlock_instructions
          email_changed
          password_changed
        )
      end
  end
end