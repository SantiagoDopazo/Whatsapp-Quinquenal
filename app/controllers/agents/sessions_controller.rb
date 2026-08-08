class Agents::SessionsController < Devise::SessionsController
  respond_to :json

  # Devise's own :destroy checks `warden.user` to decide if someone is signed
  # in, but that check is session-based and JWT auth carries no session, so it
  # always looks "already signed out" here. Skip it and require a valid token
  # via authenticate_agent! instead.
  # `authenticate_agent!` is normally a no-op inside any Devise controller
  # (force: true overrides that), since Devise assumes you don't need to
  # already be signed in to reach its own actions.
  skip_before_action :verify_signed_out_user, only: :destroy, raise: false
  before_action -> { authenticate_agent!(force: true) }, only: :destroy

  private

  def respond_with(resource, _opts = {})
    render json: AgentBlueprint.render(resource, root: :agent), status: :ok
  end
end
