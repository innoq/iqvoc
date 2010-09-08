class ConceptRelation::Base < ActiveRecord::Base
  belongs_to :owner, :class_name => 'Concept'
  belongs_to :target, :class_name => 'Concept'

  scope :published, lambda { |owner_id| {
          :joins => :target,
          :conditions => ["owner_id = #{owner_id} AND concepts.published_at IS NOT NULL"] }
  }

  scope :initial_version, lambda { |owner_id| {
          :joins => :target,
          :conditions => ["owner_id = #{owner_id} AND concepts.rev = 1 AND concepts.published_at IS NULL"] }
  }

  scope :target_in_edit_mode, lambda { |owner_id| { 
      :joins => :target,
      :include => :target,
      :conditions => "(semantic_relations.owner_id = #{owner_id}) AND (concepts.locked_by IS NOT NULL)"
    }
  }
  
end
