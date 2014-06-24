
task :setup_test_db do
  system 'RAILS_ENV=test rake db:reset db:seed'
end

task cruise: [:setup_test_db, :spec, :rubocop] do
  # system 'rake db:test:clone'   # Don't do this for Rails 4
  # system 'teaspoon -q -f tap_y | tapout pretty' # Comment out until we have CS
  # system 'rake testoutdated'
end
