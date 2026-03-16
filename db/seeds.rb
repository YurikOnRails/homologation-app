# This file should ensure the existence of records required to run the application in every environment.
# The code here should be idempotent so that it can be executed at any point in every environment.

# Roles — required in all environments
%w[super_admin coordinator teacher student].each do |role_name|
  Role.find_or_create_by!(name: role_name)
end
puts "✅ #{Role.count} roles"

# Rich fake data for local development only
if Rails.env.development?
  require_relative "seeds/development"
end
