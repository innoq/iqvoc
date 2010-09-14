class Classification < ActiveRecord::Base
  belongs_to :owner,  :class_name => Iqvoc::Concept.base_class_name
  belongs_to :target, :class_name => 'Classifier'
end