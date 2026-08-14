class HealthController < ApplicationController
  def show
    render json: { status: "up" }
  end
end
