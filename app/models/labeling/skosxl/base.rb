class Labeling::SKOSXL::Base < ActiveRecord::Base
  belongs_to :owner,  :class_name => Iqvoc::Concept.base_class_name
  belongs_to :target, :class_name => Iqvoc::Label.base_class_name
  
  scope :by_concept, lambda { |concept| {
    :conditions => { :owner_id => concept.id } }
  }
  
  scope :by_label, lambda { |label| {
    :conditions => { :target_id => label.id } }
  }

  scope :by_lang, lambda { |lang| {
    :joins => :target,
    :conditions => ["labels.language LIKE :language", { :language => lang }] }
  }

  scope :target_in_edit_mode, lambda {|owner_id| { 
    :joins => :target,
    :include => :target,
    :conditions => ["(labelings.owner_id = ?) AND (labels.locked_by IS NOT NULL)", owner_id] }
  }
  
  scope :published, lambda { |owner_id| {
    :joins => :target,
    :conditions => [
      "(labelings.owner_id = :owner_id 
      AND labels.published_at IS NOT NULL) 
      OR (labelings.owner_id = :owner_id AND labels.rev = 1 
      AND labels.published_at IS NULL)", { :owner_id => owner_id }] }
  }
  
  def self.create_for(o, t)
    find_or_create_by_owner_id_and_target_id(o.id, t.id)
  end
  
  def <=>(other)
    owner.pref_label <=> other.owner.pref_label
  end
  
end
