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

  def render_concept_association(hash, concept, association_class, furter_options = {})
    ((hash[association_class.view_section(concept)] ||= {})[association_class.view_section_sort_key(concept)] ||= "") <<
      render(association_class.partial_name(concept), furter_options.merge(:concept => concept, :klass => association_class))
  end

  def concept_view_data(concept)
    res = {}

    Iqvoc::Concept.further_labeling_classes.each do |labeling_class, languages|
      (languages || I18n.available_locales).each do |lang|
        render_concept_association(res, concept, labeling_class, :lang => lang)
      end
    end

    Iqvoc::Concept.relation_classes.each do |relation_class|
      render_concept_association(res, concept, relation_class)
    end

    Iqvoc::Concept.match_classes.each do |match_class|
      render_concept_association(res, concept, match_class)
    end

    Iqvoc::Concept.note_classes.each do |note_class|
      render_concept_association(res, concept, note_class)
    end


    %q(  

<div class="relation">
        <h3><%= t("txt.views.concepts.classifiers") %></h3>
  <div class="relation-body">
        <%=raw @concept.classifiers.map {|classifier|
      classifier.notation
    }.join(', ') %>
  </div>
</div>

<%#= render :partial => '_shared/umt_notes', :locals => {:object => @concept} %>
        <%#= render :partial => '_shared/matches', :locals => {:object => @concept} %>

%)
    res
  end
  
end
