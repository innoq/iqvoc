class Labeling::Base < ActiveRecord::Base

  set_table_name 'labelings'

  # ********** Relations

  belongs_to :owner,  :class_name => "Concept::Base"
  belongs_to :target, :class_name => "Label::Base"

  # ********** Scopes

  scope :by_concept, lambda { |concept|
    where(:owner_id => concept.id)
  }
  
  scope :by_label, lambda { |label|
    where(:target_id => label.id)
  }

  scope :concept_published, lambda {
    includes(:owner) & Concept::Base.published
  }
  
  scope :label_published, lambda {
    includes(:target) & Label::Base.published
  }

  scope :label_begins_with, lambda { |letter|
    includes(:target) & Label::Base.begins_with(letter)
  }
  
  scope :by_label_language, lambda { |lang|
    includes(:target) & Label::Base.by_language(lang)
  }

  # FIXME: There should be a validation checking this
  # Might there be more then one laeling of this type and language per concept?
  def self.only_one_allowed?
    false
  end
  
  def self.view_section(obj)
    obj.is_a?(Label::Base) ? "concepts" : "labels"
  end

  def self.view_section_sort_key(obj)
    100
  end

  def self.partial_name(obj)
    "partials/labeling/base"
  end

  def self.edit_partial_name(obj)
    "partials/labeling/edit_base"
  end

end
