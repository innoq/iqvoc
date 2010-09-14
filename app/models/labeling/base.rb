class Labeling::Base < ActiveRecord::Base

  set_table_name 'labelings'

  belongs_to :owner,  :class_name => Iqvoc::Concept.base_class_name
  belongs_to :target, :class_name => Iqvoc::Label.base_class_name
  
  scope :by_concept, lambda { |concept| {
    :conditions => { :owner_id => concept.id } }
  }
  
  scope :by_label, lambda { |label| {
    :conditions => { :target_id => label.id } }
  }
  
end
