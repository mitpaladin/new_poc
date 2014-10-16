# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

if %w(development test).include? Rails.env
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:rubocop) do |task|
    # 'spec/**/_spec*.rb',
    task.patterns = [
      'app/**/*.rb',
      'lib/**/*.rb',
      'spec/spec_helper.rb',
      'spec/controllers/**/*.rb',
      'spec/daos/**/*.rb',
      'spec/decorators/**/*.rb',
      'spec/entities/**/*.rb',
      'spec/entity_factories/**/*.rb',
      'spec/entity_support/**/*.rb',
      'spec/exploration/**/*.rb',
      'spec/factories/**/*.rb',
      'spec/features/**/*.rb',
      'spec/helpers/**/*.rb',
      'spec/interactors/**/*.rb',
      'spec/javascripts/**/*.rb',
      'spec/lib/**/*.rb',
      'spec/models/**/*.rb',
      'spec/policies/**/*.rb',
      'spec/repositories/**/*.rb',
      'spec/services/**/*.rb',
      'spec/support/**/*.rb',
      'spec/support_specs/**/*.rb'
    ]
    task.formatters = ['simple', 'd']
    task.fail_on_error = true
    task.options << '--rails'
  end

  task(:default).clear
  task default: [:spec, :rubocop]
end

Rails.application.load_tasks
