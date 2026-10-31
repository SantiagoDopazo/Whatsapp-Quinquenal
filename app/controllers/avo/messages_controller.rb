class Avo::MessagesController < Avo::ResourcesController
  prepend_before_action :read_only_messages

  private

  def read_only_messages
    head :forbidden unless request.get? || request.head?
    head :forbidden if action_name.in?(%w[new edit])
  end
end
