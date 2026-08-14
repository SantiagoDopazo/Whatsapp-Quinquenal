class Avo::Resources::Agent < Avo::BaseResource
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
    field :email, as: :text, required: true
    field :name, as: :text, required: true
    field :role, as: :select, options: Agent::ROLES.index_by(&:itself), required: true
    field :password, as: :password, only_on: :forms, required: -> { record.new_record? }
    field :password_confirmation, as: :password, only_on: :forms
    field :jti, as: :text, only_on: :show
  end
end
