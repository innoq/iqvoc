class Note::Base < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
             
  has_many :note_annotations, :dependent => :destroy
  
  accepts_nested_attributes_for :note_annotations

  scope :for_language, lambda {|lang_code|
    {:conditions => {:language => lang_code}}
  }
    
  def self.from_rdf(str)
    h = RdfHelpers.split_literal(str)
    self.new(:value => h[:value], :language => h[:language])
  end
  
  def self.from_rdf!(str)
    self.from_rdf(str).save!
  end

  def <=>(other)
    value.downcase <=> other.to_s.downcase
  end
  
  def from_annotation_list!(str)
    annotations = str.gsub(/\[|\]/, '').split('; ').map { |a| a.split(' ') }
    annotations.each do |annotation|
      note_annotations << NoteAnnotation.new(:identifier => annotation.first, :value => annotation.second)
    end
    self
  end
  
  def from_rdf(str)
    h = RdfHelpers.split_literal(str)
    self.value    = h[:value]
    self.language = h[:language]
    self
  end
    
  def to_rdf
    "\"#{value}\"@#{language}"
  end
  
  def to_s
    "#{self.value}"
  end

end
