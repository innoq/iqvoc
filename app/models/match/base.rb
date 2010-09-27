class Match::Base < ActiveRecord::Base

  set_table_name 'matches'

  # ********** Relations

  belongs_to :concept, :class_name => "Concept::Base", :foreign_key => 'concept_id'

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
