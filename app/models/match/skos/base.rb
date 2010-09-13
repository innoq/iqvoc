class Match::SKOS::Base < ActiveRecord::Base
  belongs_to :concept, :class_name => 'Concept::SKOS::Base'
end
