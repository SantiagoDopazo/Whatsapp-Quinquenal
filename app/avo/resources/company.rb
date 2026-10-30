class Avo::Resources::Company < Avo::Resources::CompanyResource
  def fields
    field :id, as: :id
    field :name, as: :text, required: true
  end
end
