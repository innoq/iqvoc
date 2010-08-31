class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = I18n.t("txt.controllers.user_sessions.login_success")
      redirect_back_or_default localized_root_path(@active_language)
    else
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = I18n.t("txt.controllers.user_sessions.logout_success")
    redirect_back_or_default new_user_session_path(:lang => @active_language)
  end
end