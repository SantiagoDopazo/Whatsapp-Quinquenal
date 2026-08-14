class AgentsController < ApplicationController
  before_action :authenticate_agent!

  def show
    render json: AgentBlueprint.render(agent)
  end

  private

  def agent
    Agent.find(params[:id])
  end
end
