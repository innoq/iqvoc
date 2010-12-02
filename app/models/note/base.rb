class Note::Base < ActiveRecord::Base
  
  set_table_name 'notes'

  # ********** Validations

  # FIXME: None?? What about language and value?

  # ********** Relations

  belongs_to :owner, :polymorphic => true
             
  has_many :annotations, :class_name => "Note::Annotated::Base", :foreign_key => :note_id, :dependent => :destroy
  
  accepts_nested_attributes_for :annotations

  # ********** Scopes

  scope :by_language, lambda { |lang_code|
    if (lang_code.is_a?(Array) && lang_code.include?(nil))
      where(arel_table[:language].eq(nil).or(arel_table[:language].in(lang_code.compact)))
    else
      where(:language => lang_code)
    end
  }
  
  scope :by_query_value, lambda { |query|
    where(Note::Base.arel_table[:value].matches(query))
  }

  scope :by_owner_type, lambda { |klass|
    where(:owner_type => klass.is_a?(ActiveRecord::Base) ? klass.name : klass)
  }

  scope :for_concepts, where(:owner_type => 'Concept::Base')
  scope :for_labels,   where(:owner_type => 'Label::Base')

  scope :by_owner, lambda { |owner|
    if owner.is_a?(Label::Base)
      for_labels.where(:owner_id => owner.id)
    elsif owner.is_a?(Concept::Base)
      for_concepts.where(:owner_id => owner.id)
    else
      raise "Note::Base.by_owner: Unknown owner (#{owner.inspect})"
    end
  }

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
      annotations << Note::Annotated::Base.new(:identifier => annotation.first, :value => annotation.second)
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

  def self.view_section(obj)
    "notes"
  end

  def self.view_section_sort_key(obj)
    100
  end

  def self.partial_name(obj)
    "partials/note/base"
  end

  def self.edit_partial_name(obj)
    "partials/note/edit_base"
  end
  
  def self.single_query(params = {})
    query_str = build_query_string(params)
    
    by_query_value(query_str).
      by_language(params[:languages].to_a)
  end
  
  def self.search_result_partial_name
    'partials/note/search/result'
  end

end
