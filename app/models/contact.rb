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
class Contact < ApplicationRecord
  validates :whatsapp_id, presence: true, uniqueness: true
end
