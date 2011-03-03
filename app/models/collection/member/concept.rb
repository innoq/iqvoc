class Collection::Member::Concept < Collection::Member::Base

  belongs_to :concept, :class_name => Iqvoc::Concept.base_class_name, :foreign_key => 'target_id'

  def self.view_section(obj)
    "main"
  end

  def self.view_section_sort_key(obj)
    100
  end

  def self.partial_name(obj)
    "partials/collection/member"
  end

end
