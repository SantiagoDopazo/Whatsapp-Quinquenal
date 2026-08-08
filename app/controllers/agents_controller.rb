class AgentsController < ApplicationController
  before_action :authenticate_agent!

  def me
    render json: AgentBlueprint.render(current_agent)
  end
end
