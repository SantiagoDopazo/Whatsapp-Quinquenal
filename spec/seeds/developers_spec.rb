require "rails_helper"

RSpec.describe "Internal developer provisioning", type: :model do
  let(:seed_file) { Rails.root.join("db/seeds.rb") }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("SEED_DEVELOPER_EMAIL").and_return(nil)
    allow(ENV).to receive(:[]).with("SEED_DEVELOPER_PASSWORD").and_return(nil)
  end

  it "does not create internal users with default credentials" do
    expect { load seed_file }.not_to change(Developer, :count)
  end

  it "requires both an email and a password when provisioning" do
    allow(ENV).to receive(:[]).with("SEED_DEVELOPER_EMAIL").and_return("internal@example.com")
    expect { load seed_file }.to raise_error(ArgumentError, /must both be configured/)
    expect(Developer.exists?(email: "internal@example.com")).to be(false)
  end

  context "with explicit configuration" do
    before do
      allow(ENV).to receive(:[]).with("SEED_DEVELOPER_EMAIL").and_return("Internal@example.com")
      allow(ENV).to receive(:[]).with("SEED_DEVELOPER_PASSWORD").and_return("synthetic-internal-password")
    end

    it "is repeatable and does not reset an existing developer's password" do
      expect { 2.times { load seed_file } }.to change(Developer, :count).by(1)
      expect(Developer.find_by!(email: "internal@example.com").valid_password?("synthetic-internal-password")).to be(true)
      allow(ENV).to receive(:[]).with("SEED_DEVELOPER_PASSWORD").and_return("changed-synthetic-password")
      load seed_file
      expect(Developer.find_by!(email: "internal@example.com").valid_password?("synthetic-internal-password")).to be(true)
    end
  end
end
