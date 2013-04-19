module WidgetHelper

  def widget_values(concept, relation_class)
    concept.relations.by_id(relation_class)
  end

  def widget_values_ranked(concept, relation_class)
    concepts_with_ranks = concept.relations.by_id_and_rank(relation_class)
    Iqvoc::InlineDataHelper.join concepts_with_ranks.map {|concept, rank| "#{concept.origin}:#{rank}" }
  end

  def widget_entities(concept, relation_class)
    origins  = Iqvoc::InlineDataHelper.split concept.relations.by_id(relation_class)
    concepts = Iqvoc::Concept.base_class.editor_selectable.by_origin(origins)
    concepts.map {|c| concept_widget_data(c) }.to_json
  end

  def widget_entities_ranked(concept, relation_class)
    origins = Iqvoc::InlineDataHelper.split concept.relations.by_id(relation_class)

    allowed_concepts    = Iqvoc::Concept.base_class.editor_selectable.by_origin(origins)
    concepts_with_ranks = concept.relations.by_id_and_rank(relation_class)

    concepts = concepts_with_ranks.select {|k, v| allowed_concepts.include?(k) }
    concepts.map {|concept, rank| concept_widget_data(cconcept, rank) }.to_json
  end

end
