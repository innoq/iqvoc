class ConceptView
  attr_accessor :title, :definition
  attr_accessor :representations

  def initialize(concept, ctx) # XXX: `ctx` should not be necessary
    @concept = concept
    @definition = @concept.notes_for_class(Note::SKOS::Definition).first.
        try(:value) # FIXME: hard-coded class, arbitrary pick

    published = @concept.published? ? nil : '0'
    @representations = [ # TODO: rename to "links"?
      { 'caption' => 'HTML', 'type' => :link, :format => :html },
      { 'caption' => 'RDF/XML', 'type' => :rdf, :format => :rdf },
      { 'caption' => 'Turtle', 'type' => :rdf, :format => :ttl },
      { 'caption' => 'N-Triples', 'type' => :rdf, :format => :nt },
      { 'caption' => ctx.t('txt.models.concept.uri'), 'type' => :link,
          'uri' => ctx.rdf_url(@concept.origin, :format => nil, :lang => nil,
              :published => published) }
    ].each do |item|
      unless item['uri'] # assume default URI, keyed on format
        format = item.delete('format')
        item['uri'] = ctx.concept_path(:id => @concept, :format => format,
            :published => published)
      end
    end
  end

end
