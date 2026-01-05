class SessionsController < ApplicationController
  def new
  end

  def create
    email = params[:email]
    password = params[:password]

    if email.present? && password.present?
      if password.length >= 6
        flash[:success] = "Login successful! (Demo)"
        redirect_to dashboards_path
      else
        flash[:error] = "Password must be at least 6 characters"
        render :new
      end
    else
      flash[:error] = "Please fill in all fields"
      render :new
    end
  end

  def destroy
    flash[:success] = "Logged out successfully! (Demo)"
    redirect_to root_path
  end
end
