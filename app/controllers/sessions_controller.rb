# frozen_string_literal: true

class SessionsController < ApplicationController
  def new; end

  def create
    email = params[:email]
    password = params[:password]

    if email.present? && password.present?
      if password.length >= 6
        flash[:success] = I18n.t("sessions.login_successful")
        redirect_to dashboards_path
      else
        flash.now[:error] = I18n.t("sessions.password_too_short")
        render :new
      end
    else
      flash[:error] = I18n.t("sessions.fill_all_fields")
      render :new
    end
  end

  def destroy
    flash[:success] = I18n.t("sessions.logged_out")
    redirect_to root_path
  end
end
