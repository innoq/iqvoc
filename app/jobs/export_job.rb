class ExportJob < Struct.new(:export, :filename, :type, :base_uri)
  def enqueue(job)
    job.delayed_reference_id   = export.id
    job.delayed_reference_type = export.class.to_s
    job.delayed_global_reference_id = export.to_global_id
    job.save!
  end

  def perform
    strio = StringIO.new

    exporter = SkosExporter.new(filename, type, base_uri, Logger.new(strio))
    exporter.run
    @messages = strio.string
  end

  def success(job)
    export.finish!(@messages)
  end

  def error(job, exception)
    export.fail!(exception)
  end
end
