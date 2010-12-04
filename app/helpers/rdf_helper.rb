module RdfHelper
  
  def render_concept(document, concept)
    document << concept.build_rdf_subject(document, controller) do |c|
      concept.labelings.each do |labeling|
        labeling.build_rdf(document, c)
      end

      concept.relations.each do |relation|
        relation.build_rdf(document, c)
      end

      concept.notes.each do |note|
        note.build_rdf(document, c)
      end

      Iqvoc::Concept.additional_association_class_names.keys.each do |class_name|
        concept.send(class_name.to_relation_name).each do |additional_object|
          additional_object.build_rdf(document, c)
        end
      end
    end
  
  end
end