class Classification < ActiveRecord::Base # FIXME: Should be a matching later!
  belongs_to :owner,  :class_name => Iqvoc::Concept.base_class_name
  belongs_to :target, :class_name => Classifier.name
end