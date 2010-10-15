class Labeling::SKOS::Base < Labeling::Base

  scope :by_label_with_language, lambda { |label, language|
    includes(:target) & self.label_class.where(:value => label, :language => language)
  }

  def self.label_class
    Iqvoc::Label.base_class
  end

  def self.partial_name(obj)
    "partials/labeling/skos/base"
  end

  def self.edit_partial_name(obj)
    nil
  end

  def self.nested_edit_partial_name(obj)
    "partials/labeling/skos/edit_base"
  end

end
