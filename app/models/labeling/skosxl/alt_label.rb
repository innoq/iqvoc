class Labeling::SKOSXL::AltLabel < Labeling::SKOSXL::Base

  def build_rdf(document, subject)
    subject.Skosxl::alt_label(target.origin)
    subject.Skos.alt_label(target.to_s, :lang => target.language)
  end

end
