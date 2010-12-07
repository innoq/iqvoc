module DashboardHelper
  
  def sorting_arrows_for(name)
    content_tag :div, :class => "sorting_arrows" do
      raw [
        link_to(image_tag("arrow_down.gif", :class => "arrow_down"), dashboard_path(:lang => @active_language, :order => "asc", :by => name.to_s)),
        link_to(image_tag("arrow_up.gif", :class => "arrow_up"), dashboard_path(:lang => @active_language, :order => "desc", :by => name.to_s))
      ]
    end
  end
  
  def consistency_status(item)
    if item.valid_with_full_validation?
      css = "valid"
      msg = "&#x2713;"
    else
      css = "invalid"
      msg = "&#x2717;"
    end
    
    content_tag :span, raw(msg), :class => css
  end
  
end