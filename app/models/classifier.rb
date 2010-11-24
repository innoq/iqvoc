class Classifier < ActiveRecord::Base # FIXME: Should be a concept in another vocabulary
  
  def self.search(query)
    return nil if query.blank?
    
    self.all(:conditions => ["notation LIKE ?", "#{query}%"])
  end
  
end