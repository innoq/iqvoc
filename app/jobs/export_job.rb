class ExportJob < Struct.new(:export, :filename, :type, :base_uri)
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
