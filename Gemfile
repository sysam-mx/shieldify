source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in shieldify.gemspec.
gemspec

gem "puma"

gem "sqlite3"

group :development, :test do
  # Start debugger with binding.b [https://github.com/ruby/debug]
  gem "debug", ">= 1.0.0"

  gem 'rack-cors'
end

group :test do
  gem 'minitest-spec-rails'
  gem 'factory_bot_rails', '~> 6.4', '>= 6.4.3'
  gem 'faker', '~> 3.3', '>= 3.3.1'
end