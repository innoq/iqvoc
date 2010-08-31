class Labeling < ActiveRecord::Base
  belongs_to :owner, :class_name => 'Concept'
  belongs_to :target, :class_name => 'Label'
  
  named_scope :by_concept, lambda { |concept| {
    :conditions => { :owner_id => concept.id }
  }}
  
  named_scope :by_label, lambda { |label| {
    :conditions => { :target_id => label.id }
  }}

  named_scope :by_lang, lambda { |lang| {
          :joins => :target,
          :conditions => ["labels.language LIKE :language", {:language => lang}]
        }
  }

  named_scope :target_in_edit_mode, lambda {|owner_id|
    { :joins => :target,
      :include => :target,
      :conditions => "(labelings.owner_id = #{owner_id}) AND (labels.locked_by IS NOT NULL)"
    }
  }
  
  def self.create_for(o, t)
    find_or_create_by_owner_id_and_target_id(o.id, t.id)
  end
  
  def <=>(other)
    owner.pref_label <=> other.owner.pref_label
  end
  
end