class Note::Base < ActiveRecord::Base
  
  set_table_name 'notes'

  # ********** Validations

  # FIXME: None?? What about language and value?

  # ********** Relations

  belongs_to :owner, :polymorphic => true
             
  has_many :annotations, :class_name => "Note::Annotated::Base", :dependent => :destroy
  
  accepts_nested_attributes_for :annotations

  # ********** Scopes

  scope :for_language, lambda { |lang_code|
    where(:language => lang_code)
  }

  scope :by_owner_type, lambda { |klass|
    where(:owner_type => klass.is_a?(ActiveRecord::Base) ? klass.name : klass)
  }

  scope :for_concepts, where(:owner_type => Iqvoc::Concept.base_class_name )
  scope :for_labels,   where(:owner_type => 'Label') # FIXME: Ohoh... perhaps with type != Iqvoc::Concept.base_class_name ? Or shouldn't we delete both scopes?

  # ********** Methods

  def self.from_rdf(str)
    h = IqvocGlobal::RdfHelper.split_literal(str)
    self.new(:value => h[:value], :language => h[:language])
  end
  
  def self.from_rdf!(str)
    self.from_rdf(str).save!
  end

  def <=>(other)
    self.to_s.downcase <=> other.to_s.downcase
  end
  
  def from_annotation_list!(str)
    str.gsub(/\[|\]/, '').split('; ').map { |a| a.split(' ') }.each do |annotation|
      annotations << NoteAnnotation.new(:identifier => annotation.first, :value => annotation.second)
    end
    self
  end
  
  def from_rdf(str)
    h = IqvocGlobal::RdfHelper.split_literal(str)
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
