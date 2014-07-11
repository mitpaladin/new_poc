
desc 'Drop, rebuild and seed database in TEST environment'
task :setup_test_db do
  system 'RAILS_ENV=test rake db:reset db:seed'
end

desc 'Run tasks as though run by CruiseControl.rb'
task cruise: [:setup_test_db, :spec, :rubocop, :notes] do
  # system 'rake notes:custom' # How to do this as a prerequisite Rake task?
  # system 'teaspoon -q -f tap_y | tapout pretty' # Comment out until we have CS
  # system 'rake testoutdated'
  system 'grep -rn NOTE app spec'
end
