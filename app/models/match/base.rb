class Match::Base < ActiveRecord::Base

  set_table_name 'matches'

  # ********** Relations

  belongs_to :concept, :class_name => Iqvoc::Concept.base_class_name


end
