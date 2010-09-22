class Match::Base < ActiveRecord::Base

  set_table_name 'matches'

  # ********** Relations

  belongs_to :concept, :class_name => Iqvoc::Concept.base_class_name

  def self.view_section(obj)
    "matches"
  end

  def self.view_section_sort_key(obj)
    100
  end

  def self.partial_name(obj)
    "partials/match/base"
  end

end
