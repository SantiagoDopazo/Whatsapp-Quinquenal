class Avo::Resources::WhatsappAccount < Avo::BaseResource
  def fields
    field :id, as: :id
    field :company, as: :belongs_to, required: true
    field :name, as: :text, required: true
    field :external_id, as: :text, required: true
    field :status, as: :select, options: WhatsappAccount::STATUSES.index_by(&:itself), required: true
  end
end
