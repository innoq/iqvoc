class ImportJob < Struct.new(:import, :filename, :user, :namespace, :publish)

  def enqueue(job)
    job.delayed_reference_id   = import.id
    job.delayed_reference_type = import.class.to_s
    job.delayed_global_reference_id = import.to_global_id
    job.save!
  end

  def perform
    strio = StringIO.new

    importer = SkosImporter.new(filename, namespace, Logger.new(strio), publish)
    importer.run
    @messages = strio.string
  end

  def success(job)
    import.finish!(@messages)
  end

  def error(job, exception)
    import.fail!(exception)
  end
end
