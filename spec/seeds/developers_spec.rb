require "rails_helper"

RSpec.describe "Internal developer provisioning", type: :model do
  let(:seed_file) { Rails.root.join("db/seeds.rb") }
  let(:developer) { Developer.find_by!(email: "developer@quinquenal.test") }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("SEED_DEVELOPER_PASSWORD").and_return("synthetic-internal-password")
  end

  it "creates the developer with the configured password" do
    expect { load seed_file }.to change(Developer, :count).by(1)
    expect(developer.name).to eq("Desarrollador")
    expect(developer.valid_password?("synthetic-internal-password")).to be(true)
  end

  it "requires a password when creating the account" do
    allow(ENV).to receive(:fetch).with("SEED_DEVELOPER_PASSWORD").and_raise(KeyError)
    expect { load seed_file }.to raise_error(KeyError)
    expect(Developer.exists?(email: "developer@quinquenal.test")).to be(false)
  end

  it "does not duplicate the account or reset its password on later runs" do
    expect { 2.times { load seed_file } }.to change(Developer, :count).by(1)
    allow(ENV).to receive(:fetch).with("SEED_DEVELOPER_PASSWORD").and_return("changed-synthetic-password")
    load seed_file
    expect(developer.valid_password?("synthetic-internal-password")).to be(true)
  end
end
