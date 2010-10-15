class Labeling::SKOSXL::PrefLabel < Labeling::SKOSXL::Base

  def build_rdf(document, subject)
    subject.Skosxl::pref_label(IqRdf.build_uri(target.origin))
    subject.Skos.pref_label(target.to_s, :lang => target.language)
  end

  def self.only_one_allowed?
    true
  end
 
end