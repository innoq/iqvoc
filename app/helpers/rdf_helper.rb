module RdfHelper
  
  def render_ttl_for_concept(concept)
    @concept = concept
    
    document = IqRdf::Document.new(configatron.rdf_data_uri_prefix)
    
    document.namespaces :skos     => "http://www.w3.org/2004/02/skos/core#", 
                    :skosxl   => "http://www.w3.org/2008/05/skos-xl#", 
                    :umt      => "http://www.uba.de/2010/03/umthes#",
                    :rdf      => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                    :rdfs     => "http://www.w3.org/2000/01/rdf-schema#",
                    :owl      => "http://www.w3.org/2002/07/owl#",
                    :xsd      => "http://www.w3.org/2001/XMLSchema#",
                    :dct      => "http://purl.org/dc/elements/1.1/",
                    :dce      => "http://purl.org/dc/elements/1.1/",
                    :gemet    => "http://www.eionet.europa.eu/gemet/concept/"

    document << IqRdf::build_uri(@concept.origin, IqRdf::Skos::build_uri("Concept")) do |concept|
      concept.Skosxl::prefLabel(IqRdf::build_uri(@concept.pref_labels.first.origin))
      concept.Skosxl::altLabel(*@concept.alt_labels.map{|alt_label| IqRdf::build_uri(alt_label.origin)}) unless @concept.alt_labels.empty?

      %w(broader narrower related).each do |relation|
        concept.Skos::build_predicate(relation, *@concept.send(relation).map{|element| IqRdf::build_uri(element.origin)}) unless @concept.send(relation).empty?
      end

      %w(historyNotes scopeNotes editorialNotes examples definitions).each do |name|
        concept.Skos::build_predicate(name.singularize, *@concept.send(name.underscore).map{|note| IqRdf::Literal.new(note, note.language) }) unless @concept.send(name.underscore).empty?
      end

      %w(exportNote changeNote sourceNote usageNote).each do |relation|
        relation_name = 'umt_' << relation.underscore.pluralize
        @concept.send(relation_name).each do |element|
          if element.note_annotations.blank?
            concept.Umt::build_predicate(relation, IqRdf::Literal.new(element, element.language))
          else
            concept.Umt::build_predicate(relation) do |blank_node|
              element.note_annotations.each do |na|
                ns, id = na.identifier.split(':')
                blank_node.send(ns.camelize).build_predicate(id, IqRdf::PlainTurtleLiteral.new(na.value))
              end
            end
          end
        end
      end
      %w(closeMatch broaderMatch narrowerMatch exactMatch).each do |relation|
        concept.Skos::build_predicate(relation, *@concept.send(relation.pluralize.underscore).map{|match| URI.parse(match.value)}) unless @concept.send(relation.pluralize.underscore).empty?
      end
      concept.Skos::build_predicate("classified", *@concept.classifiers.map{|classifier| classifier.notation}) unless @concept.classifiers.empty?
      concept.Skos::build_predicate("status", @concept.status)

    end
    
    document.to_turtle
  end
  
  def render_ttl_for_label(label_to_render)
    document = IqRdf::Document.new(configatron.rdf_data_uri_prefix)
    
    document.namespaces :skos     => "http://www.w3.org/2004/02/skos/core#", 
                    :skosxl   => "http://www.w3.org/2008/05/skos-xl#", 
                    :umt      => "http://www.uba.de/2010/03/umthes#",
                    :rdf      => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                    :rdfs     => "http://www.w3.org/2000/01/rdf-schema#",
                    :owl      => "http://www.w3.org/2002/07/owl#",
                    :xsd      => "http://www.w3.org/2001/XMLSchema#",
                    :dct      => "http://purl.org/dc/elements/1.1/",
                    :dce      => "http://purl.org/dc/elements/1.1/"

    document << IqRdf::build_uri(label_to_render.origin, IqRdf::Skos::build_uri("Label")) do |label|
      if label_to_render.base_form
        label.Umt::build_predicate("baseForm", label_to_render.base_form)
      end
      if label_to_render.part_of_speech
        label.Umt::build_predicate("partOfSpeech", label_to_render.part_of_speech)
      end
      if label_to_render.inflectional_code
        label.Umt::build_predicate("inflectionalCode", label_to_render.inflectional_code) 
      end
      %w(homograph qualifier translation).each do |name|
        label.Umt::build_predicate(name, *label_to_render.send(name.tableize).map{|relation| IqRdf::build_uri(relation.range.origin)}) unless label_to_render.send(name.tableize).empty?
      end
      unless label_to_render.compound_forms.blank?
        RAILS_DEFAULT_LOGGER.debug(label_to_render.compound_form_contents.map{|cfc| cfc.label }.inspect)
        label.Skos::build_predicate("compoundForm", label_to_render.compound_form_contents.map{|cfc| IqRdf::build_uri(cfc.label.origin)})
      end
      %w(historyNotes scopeNotes editorialNotes examples definitions).each do |name|
        label.Skos::build_predicate(name.singularize, *label_to_render.send(name.underscore).map{|note| IqRdf::Literal.new(note, note.language) }) unless label_to_render.send(name.underscore).empty?
      end
      %w(exportNote changeNote sourceNote usageNote).each do |relation|
        relation_name = 'umt_' << relation.underscore.pluralize
        label_to_render.send(relation_name).each do |element|
          if element.note_annotations.blank?
            label.Umt::build_predicate(relation, IqRdf::Literal.new(element, element.language))
          else
            label.Umt::build_predicate(relation) do |blank_node|
              element.note_annotations.each do |na|
                ns, id = na.identifier.split(':')
                blank_node.send(ns.camelize).build_predicate(id, IqRdf::PlainTurtleLiteral.new(na.value))
              end
            end
          end
        end
      end
      label_to_render.inflectionals.each do |inflectional|
        label.Umt::build_predicate("inflectional", inflectional.value)
      end
      if label_to_render.status
        label.Umt::build_predicate("status", label_to_render.status)  
      end
      label.Skosxl::build_predicate("literalForm", IqRdf::Literal.new(label_to_render.value, label_to_render.language))
    end
    
    document.to_turtle
  end
  
end