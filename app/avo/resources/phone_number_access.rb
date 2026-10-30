class Avo::Resources::PhoneNumberAccess < Avo::BaseResource
  def fields
    field :id, as: :id
    field :agent, as: :belongs_to, required: true
    field :phone_number, as: :belongs_to, required: true
  end
end
