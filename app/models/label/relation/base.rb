class Label::Relation::Base < ActiveRecord::Base
  
  set_table_name 'label_relations'
  
  belongs_to :domain, :class_name => "Label::Base"
  belongs_to :range,  :class_name => "Label::Base"
  
  scope :by_domain, lambda { |domain|
    where(:domain_id => domain)
  }

  scope :by_range, lambda { |range|
    where(:range_id => range)
  }
  
  scope :by_range_origin, lambda { |origin|
    includes(:range).merge(Label::Base.by_origin(origin))
  }

  scope :range_editor_selectable, lambda { 
   # includes(:range) & Iqvoc::XLLabel.base_class.editor_selectable # Doesn't work correctly (kills label_relations.type condition :-( )
   includes(:range).where("labels.published_at IS NOT NULL OR (labels.published_at IS NULL AND labels.published_version_id IS NULL) ")
  }

  scope :range_in_edit_mode, lambda { 
    joins(:range).merge(Iqvoc::XLLabel.base_class.in_edit_mode)
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

  def self.edit_partial_name(obj)
    "partials/label/relation/edit_base"
  end

  def self.only_one_allowed?
    false
  end
  
end
