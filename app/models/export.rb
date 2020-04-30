class Export < ApplicationRecord
  belongs_to :user

  enum file_type: [:ttl, :nt, :xml]

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
    File.join(Iqvoc.export_path, "#{token}.#{file_type}")
  end

  private

  def delete_dump_file
    File.delete(build_filename)
  end
end
