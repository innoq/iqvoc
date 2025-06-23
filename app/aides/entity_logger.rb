# frozen_string_literal: true

class EntityLogger
  def initialize(object)
    @object = object
  end

  def info(message)
    append_log(message)
  end

  def warn(message)
    append_log("[WARNING] #{message}")
  end

  def error(message)
    append_log("[ERROR] #{message}")
  end

  private

  def append_log(message)
    @object.output ||= ""
    @object.output += "#{Time.now} - #{message}\n"
    @object.save!(touch: false)
  end
end
