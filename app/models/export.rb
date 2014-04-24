class Export < ActiveRecord::Base
  belongs_to :user

  enum file_type: [:ttl, :nt, :xml]

  def finish!(messages)
    self.output = messages
    self.success = true
    self.finished_at = Time.now
    save!
  end

  def fail!(exception)
    self.output = exception.to_s + "\n\n" + exception.backtrace.join("\n")
    self.finished_at = Time.now
    save!
  end

  def build_filename
    File.join("public/export", "#{self.token.to_s}.#{self.file_type}")
  end

end
