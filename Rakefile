# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

if %w(development test).include? Rails.env
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:rubocop) do |task|
    task.patterns = [
      'app/**/*.rb',
      'lib/**/*.rb',
      'spec/**/*_spec.rb',
      'spec/support/**/*.rb'
    ]
    task.formatters = ['simple', 'd']
    task.fail_on_error = true
    task.options << '--rails'
  end

  task(:default).clear
  task default: [:spec, :rubocop]
end

Rails.application.load_tasks
