# Datos de ejemplo para una base limpia: rails db:drop db:create db:migrate db:seed

company = Company.create!(name: "La Quinquenal")

Agent.create!(email: "admin@quinquenal.test") do |agent|
  agent.company = company
  agent.name = "Admin"
  agent.role = "admin"
  agent.password = "password123"
end

developer_email = "dev@example.com"
developer_password = "password123"

Developer.create!(email: developer_email, name: "Desarrollador", password: developer_password)
