require 'iqvoc'

# inject template name
class ActionView::TemplateRenderer

  def render_with_source_comment(context, options)
    res = render_without_source_comment(context, options)
    template = determine_template(options)
    if template.formats.include?(:html)
      "<!-- Template: #{template.inspect} -->\n".html_safe << res <<
        "<!-- /Template -->\n".html_safe
    else
      res
    end
  end
  alias_method_chain :render, :source_comment

end

# inject partial name
class ActionView::PartialRenderer

  def render_with_source_comment(context, options, block)
    res = render_without_source_comment(context, options, block)
    template = find_template
    if template.formats.include?(:html)
      "<!-- Partial: #{template.inspect} -->\n".html_safe << res <<
        "<!-- /Partial -->\n".html_safe
    else
      res
    end
  end
  alias_method_chain :render, :source_comment

end

module Iqvoc::Environments

  def self.setup_development(config)
    # Settings specified here will take precedence over those in config/application.rb.

    # In the development environment your application's code is reloaded on
    # every request. This slows down response time but is perfect for development
    # since you don't have to restart the web server when you make code changes.
    config.cache_classes = false

    # Do not eager load code on boot.
    config.eager_load = false

    # Show full error reports and disable caching.
    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = false

    # Don't care if the mailer can't send.
    config.action_mailer.raise_delivery_errors = false

    # Print deprecation notices to the Rails logger.
    config.active_support.deprecation = :log

    # Raise an error on page load if there are pending migrations
    config.active_record.migration_error = :page_load

    # Debug mode disables concatenation and preprocessing of assets.
    # This option may cause significant delays in view rendering with a large
    # number of complex assets.
    config.assets.debug = true

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = false
  end

end
