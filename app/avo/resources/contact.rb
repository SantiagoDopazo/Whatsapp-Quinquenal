class Avo::Resources::Contact < Avo::Resources::CompanyResource
  # self.icon = "tabler/outline/users"
  # self.avatar = {
  #   source: :avatar
  # }
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :company, as: :belongs_to, required: true
    # field :avatar, as: :avatar
    field :whatsapp_id, as: :text
    field :name, as: :text
    field :metadata, as: :code
  end
end
