
desc 'Add demo users for ad hoc testing'
task demo_users: [:environment]  do
  UserData.new(name: 'Joe Blow',
               email: 'joe@example.com',
               profile: 'Insert generic profile *here*.',
               password: 'password',
               password_confirmation: 'password').save!
  puts "Added demo user 'Joe Blow'."
  UserData.new(name: 'John Doe',
               email: 'john@example.com',
               profile: 'Insert generic profile *here* too.',
               password: 'password',
               password_confirmation: 'password').save!
  puts "Added demo user 'John Doe'."
  puts 'Task completed.'
end
