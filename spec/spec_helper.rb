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

  # Clean database between tests
  config.before(:suite) do
    # Create tables needed for tests
    ActiveRecord::Schema.define do
      create_table :test_records, force: true do |t|
        t.integer :number
        t.string :text
        t.timestamps
      end
    end
  end

  config.after do
    # Clean up data after each test
    ActiveRecord::Base.connection.tables.each do |table|
      next if table == 'schema_migrations'

      ActiveRecord::Base.connection.execute("TRUNCATE #{table} RESTART IDENTITY CASCADE")
    end
  end
end
