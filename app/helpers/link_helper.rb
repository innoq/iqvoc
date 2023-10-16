module LinkHelper
  def link_to_object(object, name, html_options = nil, &block)
    link_to name, link_for(object), html_options, &block
  end

  def link_for(object, params = {})
    case object
    when Iqvoc::Concept.base_class
      concept_url(object, params)
    when Iqvoc::Collection.base_class
      collection_url(object, params)
    when Label::Base
      label_url(object, params)
    else
      raise 'Unsupported object type'
    end
  end
end
