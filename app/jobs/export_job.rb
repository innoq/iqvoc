require 'iqvoc/skos_exporter'

class ExportJob < Struct.new(:export, :filename, :type, :base_uri)
  def perform
    strio = StringIO.new

    exporter = Iqvoc::SkosExporter.new(filename, type, base_uri)
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
