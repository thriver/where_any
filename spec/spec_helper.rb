# frozen_string_literal: true

require 'active_record'
require 'where_any'

# Configure test database connection
db_config = YAML.load_file('config/database.yml', aliases: true)['test']
ActiveRecord::Base.establish_connection(db_config)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
