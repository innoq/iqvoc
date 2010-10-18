class Labeling::SKOSXL::HiddenLabel < Labeling::SKOSXL::Base
  
  def build_rdf(document, subject)
    subject.Skosxl::hidden_label(IqRdf.build_uri(target.origin))
    subject.Skos.hidden_label(target.to_s, :lang => target.language)
  end

  def self.view_section(obj)
    "hidden"
  end
    
  def self.searchable?
    false
  end

end
