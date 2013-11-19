require 'active_support/concern'

module Iqvoc
  module ControllerExtensions
    extend ActiveSupport::Concern

    included do
      prepend_before_filter :set_locale
      before_filter :ensure_extension

      helper :all
      helper_method :current_user_session, :current_user, :concept_widget_data, :collection_widget_data, :label_widget_data

      rescue_from ActiveRecord::RecordNotFound, :with => :handle_not_found
      rescue_from CanCan::AccessDenied, :with => :handle_access_denied
    end

    protected

    def default_url_options(options = nil)
      { :format => params[:format], :lang => I18n.locale }.
        merge(options || {})
    end

    # Force an extension to every url. (LOD)
    def ensure_extension
      unless params[:format] || !request.get?
        flash.keep
        redirect_to url_for(params.merge(:format => (request.format && request.format.symbol) || :html))
      end
    end

    def handle_access_denied(exception)
      @exception = exception
      @status = current_user ? 403 : 401
      @user_session = UserSession.new if @status == 401
      @return_url = request.fullpath
      respond_to do |format|
        format.html { render :template => 'errors/access_denied', :status => @status }
        format.any  { head @status }
      end
    end

    def handle_not_found(exception)
      @exception = exception
      SearchResultsController.prepare_basic_variables(self)

      respond_to do |format|
        format.html { render :template => 'errors/not_found', :status => 404 }
        format.any  { head 404 }
      end
    end

    def set_locale
      if params[:lang].present? && Iqvoc::Concept.pref_labeling_languages.include?(params[:lang])
        I18n.locale = params[:lang]
      else
        I18n.locale = Iqvoc::Concept.pref_labeling_languages.first
      end
    end

    def concept_widget_data(concept, rank = nil)
      data = {
        :id => concept.origin,
        :name => (concept.pref_label && concept.pref_label.value.presence || ":#{concept.origin}") + (concept.additional_info ? " (#{concept.additional_info })" : "")
      }
      data[:rank] = rank if rank
      data
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
      @current_user_session ||= UserSession.find
    end

    def current_user
      @current_user ||= current_user_session && current_user_session.user
    end

    def with_layout?
      !params[:layout]
    end

  end
end
