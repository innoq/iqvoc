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
    # In the development environment your application's code is reloaded on
    # every request.  This slows down response time but is perfect for development
    # since you don't have to restart the web server when you make code changes.
    config.cache_classes = false

    # Log error messages when you accidentally call methods on nil.
    config.whiny_nils = true

    # Show full error reports and disable caching
    config.consider_all_requests_local = true
    config.action_controller.perform_caching = false

    # Don't care if the mailer can't send
    config.action_mailer.raise_delivery_errors = false

    # Print deprecation notices to the Rails logger
    config.active_support.deprecation = :log

    # Only use best-standards-support built into browsers
    config.action_dispatch.best_standards_support = :builtin

    # Do not compress assets
    config.assets.compress = false

    # Expands the lines which load the assets
    config.assets.debug = true

    # Raise exception on mass assignment protection for Active Record models
    config.active_record.mass_assignment_sanitizer = :logger

    # Log the query plan for queries taking more than this (works
    # with SQLite, MySQL, and PostgreSQL)
    config.active_record.auto_explain_threshold_in_seconds = 0.5

    # Prepend all log lines with the following tags
    # config.log_tags = [ :subdomain, :uuid ]

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = false

    # The default URI prefix for RDF data. This will be followed by a document
    # specific shnippet like (specimenType) and the id.
  end

end
