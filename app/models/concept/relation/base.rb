class Concept::Relation::Base < ActiveRecord::Base
  
  set_table_name 'concept_relations'
  
  belongs_to :owner,  :class_name => Iqvoc::Concept.base_class_name
  belongs_to :target, :class_name => Iqvoc::Concept.base_class_name

  scope :by_owner, lambda { |owner_id| where(:owner_id => owner_id) }
  scope :published, joins(:target) & Iqvoc::Concept.base_class.published
  scope :initial_version, joins(:target) & Iqvoc::Concept.base_class.initial_version
  scope :target_in_edit_mode, joins(:target) & Iqvoc::Concept.base_class.in_edit_mode
  
  # Returnes a name for a relation holding Relation-Objects of a specific class.
  # 
  # Concept::Relation::SKOS::Narrower.relation_name # => "concept_relation_skos_narrowers"
  def self.relation_name
    name.underscore.pluralize
  end

end
