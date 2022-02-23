module LinkHelper
  def link_to_object(object, name, html_options = nil, &block)
    path = case object
           when Iqvoc::Concept.base_class
             concept_url(id: object)
           when Iqvoc::Collection.base_class
             collection_url(id: object)
           when Label::Base
             label_url(id: object)
           end

    link_to name, path, html_options, &block
  end
end
