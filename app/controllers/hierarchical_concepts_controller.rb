# FIXME: => HierarchicalConceptsController -> Concepts::HierarchicalController
class HierarchicalConceptsController < ConceptsController
  skip_before_filter :require_user
  
  def index
    case params[:root]
    when 'source'
      @concepts = Iqvoc::Concept.base_class.published.tops
    when /\d+/
      @concepts = Iqvoc::Concept.base_class.find(params[:root]).narrower.published.with_pref_labels.all
    end
    
    respond_to do |format|
      format.html { store_location }
      format.json do
        @concepts.map! do |c|
          hsh = {
            :text => c.pref_label.to_s,
            :url  => concept_path(:lang => @active_language, :id => c),
            :id   => c.id
          }
          hsh[:hasChildren] = c.narrower.any?
          hsh
        end
        render :json => @concepts.to_json
      end
    end
  end

end
