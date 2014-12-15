class ConceptView
  attr_reader :languages
  attr_reader :pref_labels, :alt_labels

  class Language
    attr_reader :id, :caption, :active

    def initialize(id, caption, active)
      @id = id # TODO: `.to_s`?
      @caption = caption
      @active = active
    end
  end

  class Link
    attr_reader :caption, :uri, :type

    def initialize(caption, uri, type = nil)
      @caption = caption
      @uri = uri
      @type = type
    end
  end

  # `h` is the controller/helper context which acts as a proxy here
  def initialize(concept, h)
    @h = h
    @concept = concept
    @published = @concept.published? ? nil : '0'
  end

  def no_content?
    definition.blank? || alt_labels.none? || related.none? || collections.none?
  end

  # returns a string
  def definition
    @definition ||= @concept.notes_for_class(Note::SKOS::Definition)
      .first # FIXME: hard-coded class, arbitrary pick
      .try(:value)
  end

  def alt_labels
    @concept.labels_for_labeling_class_and_language(Iqvoc::Concept.alt_labeling_class, I18n.locale)
  end

  # related concepts
  # returns a list of `Link`s
  def related
    klass = Iqvoc::Concept.further_relation_classes.first # XXX: arbitrary; bad heuristic?
    @related = @concept.related_concepts_for_relation_class(klass, @published).
    map do |rel_concept|
      Link.new(rel_concept.pref_label.to_s,
      h.concept_path(:id => rel_concept))
    end
  end

  # returns a list of `Link`s
  def collections
    @collections ||= @concept.collections.map do |coll|
      Link.new(coll.label.to_s, h.collection_path(:id => coll))
    end
  end

  private

  # expose private access to helper proxy in the spirit of the draper gem
  def h; @h; end

end
