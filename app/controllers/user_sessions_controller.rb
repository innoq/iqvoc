# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class UserSessionsController < ApplicationController
  
  skip_before_filter :require_user, :only => [:new, :create]

  def new
    # TODO Check abilitys

    @user_session = UserSession.new
  end

  def create
    # TODO Check abilitys

    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = I18n.t("txt.controllers.user_sessions.login_success")
      redirect_to params[:back_to] || (can?(:use, :dashboard) ? dashboard_url : root_path)
    else
      render :action => :new
    end
  end

  def destroy
    # TODO Check abilitys

    current_user_session.destroy
    flash[:notice] = I18n.t("txt.controllers.user_sessions.logout_success")
    redirect_to root_path
  end

end
