class Classification < ActiveRecord::Base
  belongs_to :owner, :class_name => 'Concept'
  belongs_to :target, :class_name => 'Classifier'
end