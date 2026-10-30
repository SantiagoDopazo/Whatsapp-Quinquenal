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

developer_email = ENV["SEED_DEVELOPER_EMAIL"]&.strip&.downcase
developer_password = ENV["SEED_DEVELOPER_PASSWORD"]

if developer_email.present? || developer_password.present?
  unless developer_email.present? && developer_password.present?
    raise ArgumentError, "SEED_DEVELOPER_EMAIL and SEED_DEVELOPER_PASSWORD must both be configured"
  end

  Developer.find_or_create_by!(email: developer_email) do |developer|
    developer.name = ENV.fetch("SEED_DEVELOPER_NAME", "Desarrollador")
    developer.password = developer_password
  end
end
