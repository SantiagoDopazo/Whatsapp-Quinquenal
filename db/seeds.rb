# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

company = Company.find_or_create_by!(name: "La Quinquenal")

Agent.find_or_create_by!(email: "admin@quinquenal.test") do |agent|
  agent.company = company
  agent.name = "Admin"
  agent.role = "admin"
  agent.password = ENV.fetch("SEED_ADMIN_PASSWORD", "password123")
end
