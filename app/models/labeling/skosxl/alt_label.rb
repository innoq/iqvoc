class Labeling::SKOSXL::AltLabel < Labeling::SKOSXL::Base

  def build_rdf(document, subject)
    subject.Skosxl::altLabel(IqRdf.build_uri(target.origin))
    subject.Skos.altLabel(target.to_s, :lang => target.language)
  end

end
