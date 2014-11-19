class ConceptView
  attr_accessor :title # TODO: title currently unused
  attr_accessor :languages # `Language`s
  attr_accessor :pref_labels, :alt_labels # indexed by language
  attr_accessor :notes # indexed by language and caption (~type)

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

    # labels and languages
    @languages = []
    @pref_labels = {}
    @alt_labels = {}
    Iqvoc::Concept.labeling_classes.each do |labeling_class, languages|
      (languages || Iqvoc.available_languages).each do |lang| # XXX: `Iqvoc.available_languages` obsolete?
        @languages << lang # XXX: doesn't belong here, e.g. due to arbitrary order

        bucket = labeling_class == Iqvoc::Concept.pref_labeling_class ?
            @pref_labels : @alt_labels
        labels = @concept.
            labels_for_labeling_class_and_language(labeling_class, lang)
        bucket[lang] = labels.map(&:value).presence
      end
    end
    @languages.uniq!.map! do |lang|
      Language.new(lang, ctx.t("languages.#{lang || '-'}"),
          lang == I18n.locale.to_s) # XXX: is this correct?
    end

    # notes
    @notes = @languages.inject({}) do |by_lang, lang| # XXX: repeatedly iterating over `@languages` -- XXX: arbitrary order?
      by_lang[lang.id] = Iqvoc::Concept.note_classes.inject({}) do |by_type, klass| # XXX: arbitrary order?
        caption = klass.model_name.human
        by_type[caption] = @concept.notes_for_class(klass).inject([]) do |memo, note|
          if note.language == lang.id # XXX: lang check inefficient across iterations?
            value = note.value
            ann = note.annotations.presence # XXX: too implicit (buried down here) -- XXX: exposing data model
            memo << [value, ann] unless value.blank? and not ann
          end
          memo
        end
        by_type
      end
      by_lang
    end
  end

  # returns a string
  def definition
    @definition ||= @concept.notes_for_class(Note::SKOS::Definition).first. # FIXME: hard-coded class, arbitrary pick
        try(:value)
  end

  # related concepts
  # returns a list of `Link`s
  def related
    klass = Iqvoc::Concept.further_relation_classes.first # XXX: arbitrary; bad heuristic?
    @related = @concept.related_concepts_for_relation_class(klass, @published).
        map do |rel_concept|
      Link.new(rel_concept.pref_label.to_s,
          @ctx.concept_path(:id => rel_concept))
    end.uniq # XXX: should not be necessary!?
  end

  # returns a list of `Link`s
  def collections
    @collections ||= @concept.collections.map do |coll|
      Link.new(coll.label.to_s, @ctx.collection_path(:id => coll))
    end.presence
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
