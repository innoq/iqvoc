class Labeling::SKOSXL::PrefLabel < Labeling::SKOSXL::Base

  def build_rdf(document, subject)
    subject.Skosxl::pref_label(IqRdf.build_uri(target.origin))
    subject.Skos.pref_label(target.to_s, :lang => target.language)
  end

  def self.only_one_allowed?
    true
  end
    
  def self.searchable?
    true
  end
  
  def self.single_query(params = {})
    query_str = build_query_string(params)
    
    Iqvoc::XLLabel.base_class.
                   by_query_value(query_str).
                   by_language(params[:languages].to_a).
                   published.
                   order("LOWER(#{Label::Base.arel_table[:value].to_sql})").
                   includes(:labelings) & Labeling::SKOSXL::PrefLabel.scoped
  end
 
end