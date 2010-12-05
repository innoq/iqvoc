class Labeling::SKOSXL::HiddenLabel < Labeling::SKOSXL::Base
  
  def build_rdf(document, subject)
    subject.Skosxl::hiddenLabel(IqRdf.build_uri(target.origin))
    subject.Skos.hiddenLabel(target.to_s, :lang => target.language)
  end

  def self.view_section(obj)
    "hidden"
  end

end
