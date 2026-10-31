require "rails_helper"

RSpec.describe Developer, type: :model do
  let_it_be(:developer) { create(:developer) }
  let(:duplicate) { build(:developer, email: developer.email) }

  it "requires a name and valid credentials without belonging to a company" do
    expect(build(:developer, name: nil)).not_to be_valid
    expect(described_class.reflect_on_association(:company)).to be_nil
    expect(developer.valid_password?("internal-password123")).to be(true)
    expect(developer.valid_password?("incorrect-password")).to be(false)
  end

  it "enforces unique internal email addresses in the database" do
    expect(duplicate).not_to be_valid
    expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
