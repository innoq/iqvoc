class Label::Base < ActiveRecord::Base

  set_table_name 'labels'

  # ********** Validations

  validate :value, :presence => true, :message => I18n.t("txt.models.label.value_error")

  # FIXME: why is there no validation for the language? (existence and format)

  # ********** Relations

  has_many :labelings, :foreign_key => 'target_id', :class_name => "Labeling::Base"

  has_many :concepts, :through => :labelings, :source => :owner

  # ********* Scopes

  scope :for_language, lambda { |lang_code|
    where(:language => lang_code)
  }

  # ********* Methods

  def <=>(other)
    self.to_s.downcase <=> other.to_s.downcase
  end

  def literal_form
    "\"#{value}\"@#{language}"
  end

  def to_s
    "#{value}"
  end

end
