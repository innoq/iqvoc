class Label::Base < ActiveRecord::Base

  set_table_name 'labels'

  # ********** Validations

  validate :value, :presence => true, :message => I18n.t("txt.models.label.value_error")

  # FIXME: why is there no validation for the language? (existence and format)

  # ********** Relations

  has_many :labelings, :foreign_key => 'target_id', :class_name => "Labeling::Base"

  has_many :concepts, :through => :labelings, :source => :owner

  # ********* Scopes

  # DEPRECATED (should be called by_language)
  scope :for_language, lambda { |lang_code|
    ActiveSupport::Deprecation.warn('Please use Labeling::Base.by_label_language instead of Labeling::Base.by_lang', caller)
    where(:language => lang_code)
  }

  scope :by_language, lambda { |lang_code|
    where(:language => lang_code)
  }

  scope :begins_with, lambda { |letter|
    where("LOWER(SUBSTR(#{Label::Base.arel_table[:value].to_sql}, 1, 1)) LIKE :letter", :letter => "#{letter.to_s.downcase}%")
  }
  
  scope :by_query_value, lambda { |query|
    where(Label::Base.arel_table[:value].matches(query))
  }

  # FIXME this comes from the SKOSXL Labelings.
  # Original:
  # scope :published, lambda { |owner_id| {
  #    :joins => :target,
  #    :conditions => [
  #      "(labelings.owner_id = :owner_id
  #    AND labels.published_at IS NOT NULL)
  #    OR (labelings.owner_id = :owner_id AND labels.rev = 1
  #    AND labels.published_at IS NULL)", { :owner_id => owner_id }] }
  # }
  #
  # Attention: This means that label classes without version controll will also
  # have to set the published_at flag to be recognized as published!!
  scope :published, lambda {
    where(arel_table['published_at'].not_eq(nil))
  }

  # FIXME: This is also defined in the mystical Common mixins included in Label::SKOSXL...
  scope :unpublished, lambda { where(arel_table['published_at'].eq(nil)) }

  # ********* Methods

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
