module ApplicationHelper
  
  def back_link(url, text=nil)
    text ||= I18n.t('txt.common.pagination.previous')
    link_to image_tag('back.png', :style => 'vertical-align: middle; margin-right: .5em') + text, url
  end

  def iqvoc_default_rdf_namespaces
    {
      :default => root_url(:format => nil, :lang => nil, :trailing_slash => true).gsub(/\/\/$/, "/"), # gsub because of a Rails bug :-(
      :rdf        => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      :rdfs       => "http://www.w3.org/2000/01/rdf-schema#",
      :owl        => "http://www.w3.org/2002/07/owl#",
      :skos       => "http://www.w3.org/2004/02/skos/core#",
      :skosxl     => "http://www.w3.org/2008/05/skos-xl#",
      :coll       => collections_url(:trailing_slash => true, :lang => nil, :format => nil)
    }
  end
  
  def options_for_language_select(selected = nil)
    locales_collection = Iqvoc.available_languages.map {|l| [l.to_s, l.to_s]}
    
    if selected
      options_for_select(locales_collection, selected)
    else
      locales_collection
    end
  end

  def user_and_phone_number(label, name, telephone_number)
    ' (' + label + ':' + name + ' (' + (telephone_number.present? ? telephone_number : '') + '))'    
  end

  def match_url(value)
    case value
    when /^\d+$/
      link_to("gemet:#{value}", "http://www.eionet.europa.eu/gemet/concept/#{value}")
    when /(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?)/ix
      link_to(value, value)
    else
      value
    end
  end
  
  def error_messages_for(object)
    if object.errors.any?
      content_tag :ul, :class => "flash_error error_list" do
        object.errors.full_messages.each do |msg|
          concat content_tag :li, msg
        end
      end
    end
  end
  
end
