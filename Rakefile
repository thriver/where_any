# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

namespace :db do
  task :prepare do
    system('dropdb where_any_test --if-exists')
    system('createdb where_any_test')
  end
end

RSpec::Core::RakeTask.new(spec: 'db:prepare')

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: %i[spec rubocop]
