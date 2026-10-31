class Avo::Resources::Conversation < Avo::BaseResource
  #   source: :avatar
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }

  def fields
    field :id, as: :id
    field :contact, as: :belongs_to
    field :phone_number, as: :belongs_to, required: -> { record.new_record? }
    field :agent, as: :belongs_to
    field :status, as: :text
    field :last_activity_at, as: :date_time
  end
end
