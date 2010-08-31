class Definition < Note
  
  named_scope :for_concepts, :conditions => { :owner_type => 'Concept' }
  named_scope :for_labels,   :conditions => { :owner_type => 'Label' }
  
  def to_s
    value
  end
  
end
