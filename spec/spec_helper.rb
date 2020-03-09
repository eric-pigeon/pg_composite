ENV["RAILS_ENV"] = "test"
require "bundler/setup"

require "database_cleaner"
require "pg_composite"

require File.expand_path("dummy/config/environment", __dir__)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  DatabaseCleaner.strategy = :transaction
  config.around(:each, db: true) do |example|
    DatabaseCleaner.start
    example.run
    DatabaseCleaner.clean
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
