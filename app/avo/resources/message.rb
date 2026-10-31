class Avo::Resources::Message < Avo::BaseResource
  self.record_selector = false

  def render_show_controls
    [ Avo::Resources::Controls::BackButton.new ]
  end

  def render_index_controls(item:)
    []
  end

  def render_row_controls(item:)
    [ Avo::Resources::Controls::ShowButton.new(item: item) ]
  end

  def fields
    field :id, as: :id
    field :conversation, as: :belongs_to
    field :phone_number, as: :belongs_to
    field :agent, as: :belongs_to
    field :direction, as: :text
    field :message_type, as: :text
    field :status, as: :text
    field :body, as: :textarea
    field :external_id, as: :text
    field :client_request_id, as: :text
    field :occurred_at, as: :date_time
    field :status_at, as: :date_time
  end
end
