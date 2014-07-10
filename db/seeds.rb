# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
title = 'Watching Paint Dry'
subtitle = 'The trusted source for drying paint news and opinion'
BlogData.delete_all
BlogData.create title: title, subtitle: subtitle

name = 'Guest User'
email = 'guest@example.com'
profile = %q(This is the un-authenticated Guest User for the system.)
UserData.delete_all
UserData.create name: name, email: email, profile: profile
