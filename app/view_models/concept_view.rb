class ConceptView
  attr_reader :title # TODO: currently unused
  attr_reader :languages # `Language`s
  attr_reader :pref_labels, :alt_labels # strings, indexed by language

  class Language # TODO: rename? -- TODO: expose for reuse? -- XXX: un-dry
    attr_reader :id, :caption, :active

    def initialize(id, caption, active)
      @id = id # TODO: `.to_s`?
      @caption = caption
      @active = active
    end
  end

  class Link # TODO: expose for reuse? -- XXX: un-dry
    attr_reader :caption, :uri, :type

    def initialize(caption, uri, type=nil)
      @caption = caption
      @uri = uri
      @type = type
    end
  end

  # `ctx` is the controller context
  def initialize(concept, ctx) # XXX: `ctx` should not be necessary -- TODO: move complex calculations into separate methods
    @ctx = ctx
    @concept = concept
    @published = @concept.published? ? nil : '0'
  end

  def no_content?
    definition.blank? || alt_labels.none? || related.none? || collections.none?
  end

  # returns a string
  def definition
    @definition ||= @concept.notes_for_class(Note::SKOS::Definition).first. # FIXME: hard-coded class, arbitrary pick
    try(:value)
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
      @ctx.concept_path(:id => rel_concept))
    end
  end

  # returns a list of `Link`s
  def collections
    @collections ||= @concept.collections.map do |coll|
      Link.new(coll.label.to_s, @ctx.collection_path(:id => coll))
    end
  end

  # resource representations
  # returns a list of typed `Link`s
  def representations
    @representations ||= [
      { 'caption' => 'HTML', 'type' => :link, :format => :html },
      { 'caption' => 'RDF/XML', 'type' => :rdf, :format => :rdf },
      { 'caption' => 'Turtle', 'type' => :rdf, :format => :ttl },
      { 'caption' => 'N-Triples', 'type' => :rdf, :format => :nt },
      { 'caption' => @ctx.t('txt.models.concept.uri'), 'type' => :link,
        'uri' => @ctx.rdf_url(@concept.origin, :format => nil, :lang => nil,
        :published => @published) }
      ].map do |item|
        unless item['uri'] # assume default URI, keyed on format
          item['uri'] = @ctx.concept_path(:id => @concept, # XXX: use `rdf_url` w/ `:lang => nil`?
          :format => item[:format], :published => @published)
        end
        Link.new(item['caption'], item['uri'], item['type'])
      end
    end

  end
