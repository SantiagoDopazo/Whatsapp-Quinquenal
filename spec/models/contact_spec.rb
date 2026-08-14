require "rails_helper"

# == Schema Information
#
# Table name: contacts
#
#  id          :bigint           not null, primary key
#  metadata    :jsonb            not null
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  whatsapp_id :string           not null
#
# Indexes
#
#  index_contacts_on_whatsapp_id  (whatsapp_id) UNIQUE
#
RSpec.describe Contact, type: :model do
  describe "validations" do
    context "without a whatsapp_id" do
      let(:contact) { described_class.new(name: "Sin Telefono") }

      before { contact.valid? }

      it "is invalid" do
        expect(contact).not_to be_valid
      end

      it "adds a presence error on whatsapp_id" do
        expect(contact.errors[:whatsapp_id]).to include("can't be blank")
      end
    end

    context "with a whatsapp_id already taken" do
      let(:existing_contact) { create(:contact) }
      let(:contact) { described_class.new(whatsapp_id: existing_contact.whatsapp_id, name: "Duplicado") }

      before { contact.valid? }

      it "is invalid" do
        expect(contact).not_to be_valid
      end

      it "adds a uniqueness error on whatsapp_id" do
        expect(contact.errors[:whatsapp_id]).to include("has already been taken")
      end
    end
  end
end
