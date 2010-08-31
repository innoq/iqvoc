class Classifier < ActiveRecord::Base
  
  def self.search(query)
    return nil if query.blank?
    
    self.all(:conditions => ["notation LIKE ?", "#{query}%"])
  end
  
end