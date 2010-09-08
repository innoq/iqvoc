class Definition < Note::Base
  
  scope :for_concepts, :conditions => { :owner_type => 'Concept' }
  scope :for_labels,   :conditions => { :owner_type => 'Label' }
  
  def to_s
    value
  end
  
end
