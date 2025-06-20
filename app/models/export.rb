class Export < ApplicationRecord
  belongs_to :user

  enum :file_type, [:ttl, :nt, :xml]

  validates_presence_of :default_namespace

  before_destroy :delete_dump_file

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
    File.join(Iqvoc.export_path, "#{self.token}.#{self.file_type}")
  end

  private

  def delete_dump_file
    if File.exist?(self.build_filename)
      Rails.logger.debug "Deleting export file #{self.build_filename}"
      File.delete(self.build_filename)
    else
      Rails.logger.debug "Export file #{self.build_filename} does not exist, cannot delete."
    end
  end
end
