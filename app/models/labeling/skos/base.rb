class Labeling::SKOS::Base < Labeling::Base

  belongs_to :target, :class_name => "Label::Base", :dependent => :destroy # the destroy is new

  scope :by_label_with_language, lambda { |label, language|
    includes(:target) & self.label_class.where(:value => label, :language => language)
  }

  def self.label_class
    Iqvoc::Label.base_class
  end

  def self.nested_editable?
    true
  end

  def self.partial_name(obj)
    "partials/labeling/skos/base"
  end

  def self.edit_partial_name(obj)
    "partials/labeling/skos/edit_base"
  end

  def self.single_query(params = {})
    query_str = build_query_string(params)

    includes(:target).order("LOWER(#{Label::Base.table_name}.value)") & Label::Base.by_query_value(query_str).by_language(params[:languages].to_a).published
  end

  def self.search_result_partial_name
    'partials/labeling/skos/search_result'
  end

  def build_search_result_rdf(document, result)
    result.Sdc::link(IqRdf.build_uri(owner.origin))
    build_rdf(document, result)
  end

end
