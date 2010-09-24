# ATTENTION:
# This class (and the inheriting subclasses) should not reference the
# Concept::Base class directly at load time!
# This means that Concept::Base may not be loaded when this class is loaded!
# So use Concept::Base ONLY in methods or procs.
#
# The reason for this lies in the fact that Concept::Base calls the
# Concept::Relation::SKOS::Broader::Base.narrower_class method to create all
# concept_relation relations. This means Concept::Base triggeres Rails to load
# the Concept::Relation::* classes. If this would trigger Rails to load
# Concept::Base we would have a loop == a problem.
class Concept::Relation::Base < ActiveRecord::Base
  
  set_table_name 'concept_relations'
  
  belongs_to :owner,  :class_name => "Concept::Base"
  belongs_to :target, :class_name => "Concept::Base"

  scope :by_owner, lambda { |owner_id| where(:owner_id => owner_id) }

  scope :by_owner_origin, lambda { |owner_id|
    includes(:owner) & Concept::Base.by_origin(owner_id)
  }

  scope :target_editor_selectable, lambda { # Lambda because Concept::Base.editor_selectable is currently not known + we don't want to call it at load time!
    includes(:target) & Concept::Base.editor_selectable
  }

  scope :published, lambda { # Lambda because Concept::Base.published is currently not known + we don't want to call it at load time!
    includes(:target) & Concept::Base.published
  }
  # scope :initial_version, joins(:target) & Concept::Base.initial_version # FIXME: Won't work because initial_version takes an agrument
  scope :target_in_edit_mode, lambda { # Lambda because Concept::Base.in_edit_mode is currently not known + we don't want to call it at load time!
    joins(:target) & Concept::Base.in_edit_mode
  }

  def self.reverse_relation_class
    self
  end

  def self.view_section(obj)
    "relations"
  end

  def self.view_section_sort_key(obj)
    100
  end

  def self.partial_name(obj)
    "partials/concept/relation/base"
  end

  def self.edit_partial_name(obj)
    "partials/concept/relation/edit_base"
  end

  def self.only_one_allowed?
    false
  end

end
