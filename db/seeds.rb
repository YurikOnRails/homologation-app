# This file should ensure the existence of records required to run the application in every environment.
# The code here should be idempotent so that it can be executed at any point in every environment.

%w[super_admin coordinator teacher student].each do |role_name|
  Role.find_or_create_by!(name: role_name)
end

puts "Seeded #{Role.count} roles"
