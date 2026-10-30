require "rails_helper"

RSpec.describe "Internal developer seed", type: :model do
  let(:seed_file) { Rails.root.join("db/seeds.rb") }
  let(:developer) { Developer.find_by!(email: "dev@example.com") }

  it "creates the example developer on a clean database" do
    expect { load seed_file }.to change(Developer, :count).by(1)
    expect(developer.name).to eq("Desarrollador")
    expect(developer.valid_password?("password123")).to be(true)
  end
end
