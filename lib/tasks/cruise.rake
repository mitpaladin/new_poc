
task :cruise do
  system 'RAILS_ENV=test rake db:reset db:seed'
  # system 'rake db:test:clone'   # Don't do this for Rails 4
  # system 'teaspoon -q -f tap_y | tapout pretty' # Comment out until we have CS
  system 'rspec' # ' -p -w'

  system 'bin/rubocop -R -f s app spec'
  # system 'rake testoutdated'
end
