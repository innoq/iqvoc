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

  # DEPRECATED: Use by_label_language instead
  scope :by_lang, lambda { |lang|
      ActiveSupport::Deprecation.warn('Please use Labeling::Base.by_label_language instead of Labeling::Base.by_lang', caller)
    {
      :joins => :target,
      :conditions => ["labels.language LIKE :language", { :language => lang }] }
  }

  scope :concept_published, includes(:owner) & Concept::Base.published
  scope :label_published, includes(:target) & Label::Base.published

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
