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
  # Must run after authenticate_agent! but before destroy signs out, since
  # current_agent goes nil the moment sign_out runs.
  before_action :set_signed_in_agent, only: :destroy

  def destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    render json: logout_message, status: :ok
  end

  private

  def set_signed_in_agent
    @signed_in_agent = current_agent
  end

  def respond_with(resource, _opts = {})
    render json: login_response, status: :ok
  end

  def login_response
    AgentBlueprint.render_as_hash(resource).merge(token: request.env["warden-jwt_auth.token"])
  end

  def logout_message
    { message: "#{@signed_in_agent.name} se desconectó" }
  end
end
