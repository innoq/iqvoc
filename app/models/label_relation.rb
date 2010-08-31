class LabelRelation < ActiveRecord::Base
  
  belongs_to :domain, :class_name => 'Label'
  belongs_to :range, :class_name => 'Label'

   named_scope :published, lambda { |domain_id| {
          :joins => :range,
          :conditions => ["(label_relations.domain_id = #{domain_id} AND labels.published_at IS NOT NULL) OR (label_relations.domain_id = #{domain_id} AND labels.rev = 1 AND labels.published_at IS NULL)"] }
  }

  named_scope :published_without_initial_versions, lambda { |domain_id| {
          :joins => :range,
          :conditions => ["(label_relations.domain_id = #{domain_id} AND labels.published_at IS NOT NULL)"] }
  }

  named_scope :range_in_edit_mode, lambda {|domain_id|
     { :joins => :range,
       :include => :range,
       :conditions => "(label_relations.domain_id = #{domain_id}) AND (labels.locked_by IS NOT NULL)"
     }
   }


end