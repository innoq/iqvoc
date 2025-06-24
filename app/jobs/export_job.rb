class ExportJob < Struct.new(:export, :filename, :type, :base_uri)
  def enqueue(job)
    job.delayed_reference_id   = export.id
    job.delayed_reference_type = export.class.to_s
    job.delayed_global_reference_id = export.to_global_id
    job.save!
  end

  def perform
    exporter = SkosExporter.new(filename, type, base_uri, EntityLogger.new(export))
    exporter.run
  end

  def success(_job)
    export.finish!
  end

  def error(_job, exception)
    export.fail!(exception)
  end
end
