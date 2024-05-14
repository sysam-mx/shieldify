require_relative "lib/shieldify/version"

Gem::Specification.new do |spec|
  spec.name        = "shieldify"
  spec.version     = Shieldify::VERSION
  spec.authors     = ["Armando Alejandre"]
  spec.email       = ["armando1339@gmail.com"]
  spec.homepage    = "https://rubygems.org/"
  spec.summary     = "Authentication solution for Rails APIs."
  spec.description = "Authentication solution for Rails APIs."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org/"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://rubygems.org/"
  spec.metadata["changelog_uri"] = "https://rubygems.org/"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.3"
  spec.add_dependency "bcrypt", "~> 3.1", ">= 3.1.20"
  spec.add_dependency "warden", "~> 1.2", ">= 1.2.9"
  spec.add_dependency "jwt", "~> 2.8", ">= 2.8.1"
end
