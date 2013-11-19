module LinkHelper
  def link_to_object(object, name, html_options = nil, &block)
    path = case object
    when Iqvoc::Concept.base_class
      concept_path(:id => object)
    when Iqvoc::Collection.base_class
      collection_path(:id => object)
    when Label::Base
      label_path(:id => object)
    end

    link_to name, path, html_options, &block
  end
end
