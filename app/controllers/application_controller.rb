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

class ApplicationController < ActionController::Base

  prepend_before_filter :set_locale
  before_filter :ensure_extension
  before_filter :require_user

  helper :all
  helper_method :current_user_session, :current_user, :concept_widget_data, :collection_widget_data, :label_widget_data#, :render_label

  rescue_from ActiveRecord::RecordNotFound, :with => :handle_not_found
  rescue_from CanCan::AccessDenied, :with => :handle_access_denied

  protect_from_forgery

  protected

  def default_url_options(options = nil)
    { :format => :html, :lang => I18n.locale }.
      reject { |key, value| key == :lang and value.blank? }. # Strip out the lang parameter if it's empty.
      merge(options || {})
  end

  # Force an extension to every url. (LOD)
  def ensure_extension
    redirect_to url_for(params.merge(:format => (request.format && request.format.symbol) || :html)) unless params[:format]
  end

  def handle_access_denied(exception)
    @exception = exception
    render :template => 'errors/access_denied', :status => :access_denied
  end

  def handle_multiple_choices(exception)
    @exception = exception
    render :template => 'errors/multiple_choices', :status => :multiple_choices
  end

  def handle_not_found(exception)
    @exception = exception
    @available_languages = (Iqvoc.available_languages + Iqvoc::Concept.labeling_class_names.values.flatten).uniq.each_with_object({}) do |lang_sym, hsh|
      lang_sym ||= "none"
      hsh[lang_sym.to_s] = t("languages.#{lang_sym.to_s}", :default => lang_sym.to_s)
    end

    render :template => 'errors/not_found', :status => :not_found
  end

  def handle_virtuoso_exception(exception)
    logger.error "Virtuoso Exception: " + exception
    flash[:error] = t("txt.controllers.versioning.virtuoso_exception") + " " + exception
  end

  def set_locale
    if Iqvoc::Concept.pref_labeling_languages.include?(nil)
      I18n.locale = " "
    elsif params[:lang] && Iqvoc::Concept.pref_labeling_languages.include?(params[:lang].to_sym)
      I18n.locale = params[:lang]
    else
      I18n.locale = Iqvoc::Concept.pref_labeling_languages.first
    end
  end

  def concept_widget_data(concept)
    {
      :id => concept.origin,
      :name => concept.pref_label.value.to_s + (concept.additional_info ? " (#{concept.additional_info })" : "")
    }
  end

  def collection_widget_data(collection)
    {
      :id => collection.origin,
      :name => collection.pref_label.to_s
    }
  end

  def label_widget_data(label)
    {
      :id => label.origin,
      :name => label.value
    }
  end

  # Configurable Ability class
  def current_ability
    @current_ability ||= Iqvoc.ability_class.new(current_user)
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def require_user
    unless current_user
      flash[:error] = I18n.t("txt.controllers.application.login_required")
      redirect_to new_user_session_url(:back_to => request.fullpath)
      return false
    end
  end

  def require_no_user
    if current_user
      flash[:error] = I18n.t("txt.controllers.application.logout_required")
      redirect_to root_path
      return false
    end
  end

end
