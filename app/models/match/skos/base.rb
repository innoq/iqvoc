class Match::SKOS::Base < ActiveRecord::Base
  belongs_to :concept, :class_name => Iqvoc::Concept.base_class_name
end
