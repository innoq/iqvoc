class Labeling::SKOS::Base < Labeling::Base

  belongs_to :owner, :class_name => Iqvoc::Concept.base_class_name
  belongs_to :target, :class_name => "Label::Base", :dependent => :destroy # the destroy is new

  scope :by_label_with_language, lambda { |label, language|
    includes(:target) & self.label_class.where(:value => label, :language => language)
  }

  def self.label_class
    Iqvoc::Label.base_class
  end

  def self.partial_name(obj)
    "partials/labeling/skos/base"
  end

  def self.edit_partial_name(obj)
    "partials/labeling/skos/edit_base"
  end

  def self.single_query(params = {})
    query_str = build_query_string(params)

    scope = includes(:target).order("LOWER(#{Label::Base.table_name}.value)")

    if params[:query].present?
      scope = scope & Label::Base.by_query_value(query_str).by_language(params[:languages].to_a).published
    else
      scope = scope & Label::Base.by_language(params[:languages].to_a).published
    end

    if params[:collection_origin].present?
      scope = scope.includes(:owner => { :collection_members => :collection })
      scope = scope & Collection::Base.where(:origin => params[:collection_origin])
    end

    # Check that the included concept is in published state:
    scope = scope.includes(:owner) & Iqvoc::Concept.base_class.published

    scope
  end

  def self.search_result_partial_name
    'partials/labeling/skos/search_result'
  end

  def build_search_result_rdf(document, result)
    result.Sdc::link(IqRdf.build_uri(owner.origin))
    build_rdf(document, result)
  end

end
