class Labeling::SKOSXL::Base < Labeling::Base

  # FIXME
  scope :target_in_edit_mode, lambda {|owner_id| { 
      :joins => :target,
      :include => :target,
      :conditions => ["(labelings.owner_id = ?) AND (labels.locked_by IS NOT NULL)", owner_id] }
  }

  scope :by_label_origin, lambda { |origin|
    includes(:target) & self.label_class.by_origin(origin)
  }

  scope :label_editor_selectable, lambda { # Lambda because self.label_class is currently not known + we don't want to call it at load time!
    includes(:target) & self.label_class.editor_selectable
  }
  
  def self.create_for(o, t)
    find_or_create_by_owner_id_and_target_id(o.id, t.id)
  end

  # FIXME: Hmm... Why should I sort labelings (not necessarily pref_labelings) by pref_label???
  def <=>(other)
    owner.pref_label <=> other.owner.pref_label
  end

  def self.label_class
    Iqvoc::XLLabel.base_class
  end

end
