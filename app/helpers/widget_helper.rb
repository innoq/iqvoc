module WidgetHelper

  def widget_values(concept, relation_class)
    concept.concept_relations_by_id(relation_class.name.to_relation_name)
  end

  def widget_values_ranked(concept, relation_class)
    concepts_with_ranks = concept.concept_relations_by_id_and_rank(relation_class.name.to_relation_name)
    res = concepts_with_ranks.map { |concept, rank| "#{concept.origin}:#{rank}" }
    Iqvoc::InlineDataHelper.generate_inline_values(res)
  end

  def widget_entities(concept, relation_class)
    origins = concept.
      concept_relations_by_id(relation_class.name.to_relation_name)
    origins = Iqvoc::InlineDataHelper.parse_inline_values(origins)

    Iqvoc::Concept.base_class.
      editor_selectable.
      by_origin(origins).
      map { |c| concept_widget_data(c) }.
      to_json
  end

  def widget_entities_ranked(concept, relation_class)
    origins = concept.
      concept_relations_by_id(relation_class.name.to_relation_name)
    origins = Iqvoc::InlineDataHelper.parse_inline_values(origins)

    allowed_concepts = Iqvoc::Concept.base_class.
      editor_selectable.
      by_origin(origins)

    concepts_with_ranks = concept.concept_relations_by_id_and_rank(relation_class.name.to_relation_name)

    concepts = concepts_with_ranks.reject { |k, v| !allowed_concepts.include?(k) }
    concepts.map { |c, r| concept_widget_data(c, r) }.to_json
  end

end
