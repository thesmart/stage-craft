require_relative '../config/initializers/stage_craft_app'

User.all.each do |user|
  puts "Processing user: #{user.id}"
  # do something with every user in the database
  puts "Completed user: #{user.id}"
end
