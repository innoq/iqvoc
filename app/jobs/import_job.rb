require 'iqvoc/skos_importer'

class ImportJob < Struct.new(:import, :content, :user, :namespace, :publish)
  def perform
    strio = StringIO.new

    importer = Iqvoc::SkosImporter.new(content.to_s.split("\n"), namespace, Logger.new(strio), publish)
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
