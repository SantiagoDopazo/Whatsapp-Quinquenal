class AgentsController < ApplicationController
  before_action :authenticate_agent!

  def show
    render json: AgentBlueprint.render(agent)
  end

  private

  def agent
    current_agent.company.agents.find(params[:id])
  end
end
