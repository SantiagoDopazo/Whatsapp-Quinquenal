class Avo::Resources::Company < Avo::BaseResource
  def fields
    field :id, as: :id
    field :name, as: :text, required: true
  end
end
