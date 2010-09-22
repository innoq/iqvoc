class CompoundForm::Base < ActiveRecord::Base

  set_table_name 'compound_forms'
  
  belongs_to :domain, :class_name => 'Label::Base', :foreign_key => 'domain_id'
  
  has_many :compound_form_contents, 
           :class_name  => 'CompoundForm::Content::Base', 
           :foreign_key => 'compound_form_id', 
           :dependent   => :destroy

  scope :published, includes(:domain) & Label::Base.published
  
end
