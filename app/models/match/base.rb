class Match::Base < ActiveRecord::Base

  set_table_name 'matches'

  belongs_to :concept, :class_name => Iqvoc::Concept.base_class_name
end
