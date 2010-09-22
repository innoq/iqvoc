class Label::Relation::Base < ActiveRecord::Base
  
  set_table_name 'label_relations'
  
  belongs_to :domain, :class_name => Iqvoc::Label.base_class_name
  belongs_to :range,  :class_name => Iqvoc::Label.base_class_name
  
  # FIXME
  scope :range_in_edit_mode, lambda {|domain_id| { 
    :joins => :range,
    :include => :range,
    :conditions => "(label_relations.domain_id = #{domain_id}) AND (labels.locked_by IS NOT NULL)" }
   }

  def self.view_section(obj)
    "relations"
  end

  def self.view_section_sort_key(obj)
    100
  end

  def self.partial_name(obj)
    "partials/label/relation/base"
  end

end
