class Label::Base < ActiveRecord::Base

  set_table_name 'labels'

  # ********** Validations

  validates :value, :presence => {:message => I18n.t("txt.models.label.value_error")}

  # FIXME: why is there no validation for the language? (existence and format)

  # ********** Relations

  has_many :labelings, :foreign_key => 'target_id', :class_name => "Labeling::Base"

  has_many :concepts, :through => :labelings, :source => :owner

  # ********* Scopes

  scope :by_language, lambda { |lang_code|
    if (lang_code.is_a?(Array) && lang_code.include?(nil))
      where(arel_table[:language].eq(nil).or(arel_table[:language].in(lang_code.compact)))
    else
      where(:language => lang_code)
    end
  }

  scope :begins_with, lambda { |letter|
    where("LOWER(SUBSTR(#{Label::Base.table_name}.value, 1, 1)) = :letter", :letter => letter.to_s.downcase)
  }
  
  scope :by_query_value, lambda { |query|
    where(["LOWER(#{table_name}.value) LIKE ?", query.to_s.downcase])
  }

  # Attention: This means that even label classes without version controll will also
  # have to set the published_at flag to be recognized as published!!
  scope :published, lambda {
    where(arel_table['published_at'].not_eq(nil))
  }

  scope :unpublished, lambda { where(arel_table['published_at'].eq(nil)) }

  # ********* Methods

  def published?
    true
  end

  def <=>(other)
    self.to_s.downcase <=> other.to_s.downcase
  end

  def to_literal
    "\"#{value}\"@#{language}"
  end

  def to_s
    "#{value}"
  end

end
