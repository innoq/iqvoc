class CollectionLabel < ActiveRecord::Base

  belongs_to :collection, :class_name => 'Collection::Base'

  scope :by_language, lambda { |lang_code|
    if (lang_code.is_a?(Array) && lang_code.include?(nil))
      where(arel_table[:language].eq(nil).or(arel_table[:language].in(lang_code.compact)))
    else
      where(:language => lang_code)
    end
  }

  scope :by_query_value, lambda { |query|
    where(["LOWER(#{table_name}.value) LIKE ?", query.to_s.downcase])
  }

  def self.edit_partial_name(obj)
    'partials/collection_label/edit'
  end

  def self.search_result_partial_name
    'partials/collection_label/search_result'
  end

  def self.single_query(params = {})
    query_str = build_query_string(params)

    scope = includes(:collection)

    if params[:query].present?
      scope = scope.by_query_value(query_str).by_language(params[:languages].to_a)
    else
      scope = scope.by_language(params[:languages].to_a)
    end

    scope
  end

  def build_rdf(document, subject)
    subject.Rdfs::label(self.value, :lang => self.language)
  end

  def to_s
    value
  end

end
