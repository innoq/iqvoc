class LanguageSwitchController < ApplicationController
  skip_before_filter :require_user
  
  def index
    redirect_to localized_root_path(:lang => I18n.default_locale)
  end
  
end