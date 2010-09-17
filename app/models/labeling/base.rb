class Labeling::Base < ActiveRecord::Base

  set_table_name 'labelings'

  # ********** Relations

  belongs_to :owner,  :class_name => Iqvoc::Concept.base_class_name
  belongs_to :target, :class_name => Iqvoc::Label.base_class_name

  # ********** Scopes

  scope :by_concept do |concept|
    where(:owner_id => concept.id)
  end
  
  scope :by_label do |label|
    where(:target_id => label.id)
  end

    scope :by_lang, lambda { |lang| {
      :joins => :target,
      :conditions => ["labels.language LIKE :language", { :language => lang }] }
  }
  
end
