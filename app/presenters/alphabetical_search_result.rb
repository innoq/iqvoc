class AlphabeticalSearchResult
  delegate :url_helpers, :to => 'Rails.application.routes'

  def initialize(pref_labeling)
    @labeling = pref_labeling
  end

  def label
    @labeling.target
  end

  def concept
    @labeling.owner
  end

  def path
    url_helpers.rdf_path(@labeling.owner.origin, :lang => nil, :format => nil)
  end

  def definition?
    relation_name = Note::SKOS::Definition.name.to_relation_name
    @labeling.owner.respond_to?(relation_name) && @labeling.owner.send(relation_name).any?
  end

  def definition
    relation_name = Note::SKOS::Definition.name.to_relation_name
    @labeling.owner.send(relation_name).first
  end

  def partial_name
    'concepts/alphabetical/search_result'
  end
end
