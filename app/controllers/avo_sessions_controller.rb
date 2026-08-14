class AvoSessionsController < ActionController::Base
  layout false

  def new
  end

  def create
    agent = Agent.find_by(email: params[:email])

    if agent&.valid_password?(params[:password])
      sign_in(:agent, agent)
      redirect_to "/avo"
    else
      flash.now[:alert] = "Email o contraseña inválidos"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out(:agent)
    redirect_to "/login"
  end
end
