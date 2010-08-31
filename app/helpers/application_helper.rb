# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def back_link(url, text=nil)
    text ||= I18n.t('txt.common.pagination.previous')
    link_to image_tag('back.png', :style => 'vertical-align: middle; margin-right: .5em') + text, url
  end
  
  def options_for_language_select(selected = nil)
    locales_collection = I18n.available_locales.map {|l| [l.to_s, l.to_s]}
    
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
      when /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
        link_to(value, value)
    end
  end
end