module ConceptsHelper
  def select_search_checkbox?(lang)
    params[:languages] && params[:languages].include?(lang.to_s)
  end
  
  def quote_turtle_value(str)
    str.match(/^<.*>$/) ? str : "\"#{str}\""
  end
  
  def treeview(root = "source")
    render :partial => "hierarchical_concepts/treeview", :locals => { :root => root }
  end
  
end
