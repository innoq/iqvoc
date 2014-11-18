class ConceptView
  attr_accessor :title, :definition # TODO: title currently unused
  attr_accessor :collections # `[{ caption, uri }]`
  attr_accessor :languages # `[{ id, caption, active }]`
  attr_accessor :pref_labels, :alt_labels # indexed by language
  attr_accessor :notes # indexed by language and caption (~type)
  attr_accessor :representations # `[{ caption, uri, type }]`

  def initialize(concept, ctx) # XXX: `ctx` should not be necessary -- TODO: move complex calculations into separate methods
    @concept = concept
    @definition = @concept.notes_for_class(Note::SKOS::Definition).first.
        try(:value) # FIXME: hard-coded class, arbitrary pick
    @collections = @concept.collections.map do |coll|
      OpenStruct.new :caption => coll.label.to_s,
          :uri => ctx.collection_path(:id => coll)
    end.presence

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
      OpenStruct.new(:id => lang, :caption => ctx.t("languages.#{lang || '-'}"),
          :active => lang == I18n.locale.to_s) # XXX: is this correct?
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

    # resource representations
    published = @concept.published? ? nil : '0'
    @representations = [ # TODO: rename to "links"?
      { 'caption' => 'HTML', 'type' => :link, :format => :html },
      { 'caption' => 'RDF/XML', 'type' => :rdf, :format => :rdf },
      { 'caption' => 'Turtle', 'type' => :rdf, :format => :ttl },
      { 'caption' => 'N-Triples', 'type' => :rdf, :format => :nt },
      { 'caption' => ctx.t('txt.models.concept.uri'), 'type' => :link,
          'uri' => ctx.rdf_url(@concept.origin, :format => nil, :lang => nil,
              :published => published) }
    ].map do |item|
      unless item['uri'] # assume default URI, keyed on format
        item['uri'] = ctx.concept_path(:id => @concept,
            :format => item[:format], :published => published)
      end
      OpenStruct.new(:caption => item['caption'], :uri => item['uri'],
          :type => item['type'])
    end
  end

end
