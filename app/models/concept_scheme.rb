class ConceptScheme < ActiveRecord::Base

  has_many :concept_scheme_relations,
           :foreign_key => 'in_scheme_id'
  has_many :top_concepts,
           :through => :concept_scheme_relations,
           :foreign_key => :top_concept_id
end
