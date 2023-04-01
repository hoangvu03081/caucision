# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

WebMock.disable_net_connect!(allow_localhost: true)

RSpec::Matchers.define_negated_matcher :not_change, :change

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = [:deletion, { except: %w(spatial_ref_sys) }]
    DatabaseCleaner.clean_with :truncation, except: %w(spatial_ref_sys)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
