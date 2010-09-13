class LabelRelation::Base < ActiveRecord::Base
  
  set_table_name 'label_relations'
  
  belongs_to :domain, :class_name => 'Label::SKOSXL::Base'
  belongs_to :range,  :class_name => 'Label::SKOSXL::Base'

   scope :published, lambda { |domain_id| {
    :joins => :range,
    :conditions => ["(label_relations.domain_id = #{domain_id} AND labels.published_at IS NOT NULL) OR (label_relations.domain_id = #{domain_id} AND labels.rev = 1 AND labels.published_at IS NULL)"] }
  }

  scope :published_without_initial_versions, lambda { |domain_id| {
    :joins => :range,
    :conditions => ["(label_relations.domain_id = #{domain_id} AND labels.published_at IS NOT NULL)"] }
  }

  scope :range_in_edit_mode, lambda {|domain_id| { 
    :joins => :range,
    :include => :range,
    :conditions => "(label_relations.domain_id = #{domain_id}) AND (labels.locked_by IS NOT NULL)" }
   }

end
