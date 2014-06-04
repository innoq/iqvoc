# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
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

class UsersController < ApplicationController
  def index
    @users = User.all
    authorize! :read, User
  end

  def new
    authorize! :create, User
    @user = User.new
  end

  def create
    authorize! :create, User
    @user = User.new(user_params)

    if @user.save
      flash[:success] = I18n.t('txt.controllers.users.successfully_created')
      redirect_to users_path
    else
      render action: :new
    end
  end

  def edit
    @user = User.find(params[:id])
    authorize! :update, @user
  end

  def update
    @user = User.find(params[:id])
    authorize! :update, @user

    if @user.update_attributes(user_params)
      flash[:success] = I18n.t('txt.controllers.users.successfully_updated')
      redirect_to users_path
    else
      render action: :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    authorize! :destroy, @user

    @user.destroy

    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:forename, :surname, :email, :password,
                                 :password_confirmation, :active, :role,
                                 :telephone_number)
  end
end
