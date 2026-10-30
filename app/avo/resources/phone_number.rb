class Avo::Resources::PhoneNumber < Avo::Resources::CompanyResource
  def fields
    field :id, as: :id
    field :whatsapp_account, as: :belongs_to, required: true
    field :name, as: :text, required: true
    field :external_id, as: :text, required: true
    field :display_phone_number, as: :text, required: true
    field :status, as: :select, options: PhoneNumber::STATUSES.index_by(&:itself), required: true
  end
end
