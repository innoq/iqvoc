module Publishable
  extend ActiveSupport::Concern

  included do
    after_initialize do
      disable_validations_for_publishing
    end
  end

  def enable_validations_for_publishing
    @_run_validations_for_publishing = true
  end

  def disable_validations_for_publishing
    @_run_validations_for_publishing = false
  end

  def validatable_for_publishing?
    @_run_validations_for_publishing ? true : false
  end

  def publish!
    enable_validations_for_publishing
    save!
  end

  def publishable?
    enable_validations_for_publishing
    valid?
  end
end
