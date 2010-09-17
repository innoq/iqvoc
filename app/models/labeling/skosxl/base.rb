class Labeling::SKOSXL::Base < Labeling::Base

  # FIXME
  scope :target_in_edit_mode, lambda {|owner_id| { 
      :joins => :target,
      :include => :target,
      :conditions => ["(labelings.owner_id = ?) AND (labels.locked_by IS NOT NULL)", owner_id] }
  }
  
  # FIXME
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

  # FIXME: Hmm... Why should I sort labelings (not necessarily pref_labelings) by pref_label???
  def <=>(other)
    owner.pref_label <=> other.owner.pref_label
  end
  
end
