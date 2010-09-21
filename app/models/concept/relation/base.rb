class Concept::Relation::Base < ActiveRecord::Base
  
  set_table_name 'concept_relations'
  
  belongs_to :owner,  :class_name => "Concept::Base"
  belongs_to :target, :class_name => "Concept::Base"

  scope :by_owner, lambda { |owner_id| where(:owner_id => owner_id) }
  scope :published, joins(:target) & Concept::Base.published
 # scope :initial_version, joins(:target) & Concept::Base.initial_version # FIXME: Won't work because initial_version takes an agrument
  scope :target_in_edit_mode, joins(:target) & Concept::Base.in_edit_mode

  def self.view_section
    "relations"
  end

  def self.view_section_sort_key
    100
  end

  def self.partial_name
    "partials/concept/relation/base"
  end

end
