class AvoSessionsController < ActionController::Base
  layout false
  protect_from_forgery with: :exception

  def new
  end

  def create
    developer = Developer.find_for_database_authentication(email: params[:email])

    if developer&.valid_password?(params[:password])
      reset_session
      sign_in(:developer, developer)
      redirect_to "/avo"
    else
      flash.now[:alert] = "Email o contraseña inválidos"
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    sign_out(:developer)
    redirect_to "/login"
  end
end
