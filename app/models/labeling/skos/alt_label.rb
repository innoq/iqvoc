class Labeling::SKOS::AltLabel < Labeling::SKOS::Base

  def build_rdf(document, subject)
    subject.Skos.alt_label(target.to_s, :lang => target.language)
  end

end
