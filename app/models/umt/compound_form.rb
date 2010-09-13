class UMT::CompoundForm < ActiveRecord::Base
  
  belongs_to :domain, :class_name => 'Label::SKOSXL::Base'
  
  has_many :compound_form_contents, 
           :class_name  => 'UMT::CompoundFormContent', 
           :foreign_key => 'compound_form_id', 
           :dependent   => :destroy

end
