class ApplicationController < ActionController::Base

  before_filter :ensure_extension

  before_filter :load_languages
  before_filter :set_locale
  before_filter :require_user
  
  helper :all
  helper_method :current_user_session, :current_user

  rescue_from ActiveRecord::RecordNotFound, :with => :handle_not_found
  rescue_from CanCan::AccessDenied, :with => :handle_access_denied

  protect_from_forgery

  protected

  def default_url_options(options = nil)
    {:format => :html}.merge(options || {})
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
    render :template => 'errors/not_found', :status => :not_found
  end
  
  def handle_virtuoso_exception(exception)
    logger.error "Virtuoso Exception: " + exception
    flash[:error] = t("txt.controllers.versioning.virtuoso_exception") + " " + exception
  end

  def load_languages
    @available_languages = {
      'Deutsch' =>         :de,
      'English' =>         :en
    }
  end

  def set_locale
    if request.headers['HTTP_ACCEPT_LANGUAGE'] =~ /#{I18n.available_locales.join('|')}/
      req_lang = $1
    end
    @active_language = params[:lang] ? params[:lang] : req_lang
    I18n.locale = @active_language
  end
  
  private
  
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
      store_location
      flash[:error] = I18n.t("txt.controllers.application.login_required")
      redirect_to new_user_session_url(:lang => I18n.locale)
      return false
    end
  end
 
  def require_no_user
    if current_user
      store_location
      flash[:error] = I18n.t("txt.controllers.application.logout_required")
      redirect_to localized_root_path(:lang => @active_language)
      return false
    end
  end
    
  def store_location
    session[:return_to] = request.fullpath
  end
    
  def redirect_back_or_default(default = nil)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
