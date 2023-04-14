source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'rails', '~> 7.0.4', '>= 7.0.4.3'

gem 'dotenv-rails'

gem 'http'

# ScyllaDB
gem 'cassandra-driver'
gem 'sorted_set'

gem 'polars-df'

# Auth
gem 'devise'
gem 'doorkeeper'
gem 'doorkeeper-jwt'
gem 'doorkeeper-openid_connect'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'activerecord-session_store'

# API Handling
gem 'active_model_serializers'
gem 'dry-validation'

group :test, :development do
  gem 'awesome_print'
  gem 'pry-byebug', '~> 3.10'
  gem 'rubocop', require: false
  gem 'yamllint'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'factory_bot', '~> 6.2'
  gem 'fuubar'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'spring-commands-rspec'
  gem 'webmock'
end

# group :development do
#   gem 'spring'
# end

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
