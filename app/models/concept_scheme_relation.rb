class ConceptSchemeRelation < ActiveRecord::Base
  belongs_to :top_concept,
             :class_name => 'Concept'
  belongs_to :concept_scheme,
             :foreign_key => 'in_scheme_id'
end
