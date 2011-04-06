class Labeling::SKOSXL::Base < Labeling::Base

  scope :target_in_edit_mode, lambda {
    includes(:target).merge(Iqvoc::XLLabel.base_class.in_edit_mode)
  }

  scope :by_label_origin, lambda { |origin|
    includes(:target).merge(self.label_class.by_origin(origin))
  }

  scope :by_label_language, lambda { |language|
    includes(:target).merge(self.label_class.by_language(language))
  }

  scope :label_editor_selectable, lambda { # Lambda because self.label_class is currently not known + we don't want to call it at load time!
    includes(:target).merge(self.label_class.editor_selectable)
  }

  def self.create_for(o, t)
    find_or_create_by_owner_id_and_target_id(o.id, t.id)
  end

  # FIXME: Hmm... Why should I sort labelings (not necessarily pref_labelings) by pref_label???
  def <=>(other)
    owner.pref_label <=> other.owner.pref_label
  end

  def self.label_class
    Iqvoc::XLLabel.base_class
  end

  def self.single_query(params = {})
    query_str = build_query_string(params)

    scope = includes(:target).order("LOWER(#{Label::Base.table_name}.value)")

    if params[:query].present?
      scope = scope.merge(Label::Base.by_query_value(query_str).by_language(params[:languages].to_a).published)
    else
      scope = scope.merge(Label::Base.by_language(params[:languages].to_a).published)
    end

    if params[:collection_origin].present?
      scope = scope.includes(:owner => { :collection_members => :collection })
      scope = scope.merge(Collection::Base.where(:origin => params[:collection_origin]))
    end

    # Check that the included concept is in published state:
    scope = scope.includes(:owner).merge(Iqvoc::Concept.base_class.published)

    unless params[:collection_origin].blank?
      #
    end

    scope
  end

  def self.search_result_partial_name
    'partials/labeling/skosxl/search_result'
  end

  def self.partial_name(obj)
    "partials/labeling/skosxl/base"
  end

  def self.edit_partial_name(obj)
    "partials/labeling/skosxl/edit_base"
  end

  def build_search_result_rdf(document, result)
    result.Sdc::link(IqRdf.build_uri(owner.origin))
    build_rdf(document, result)
  end

end
