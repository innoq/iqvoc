# FIXME: => HierarchicalConceptsController -> Concepts::HierarchicalController
class HierarchicalConceptsController < ConceptsController
  skip_before_filter :require_user
  
  def index
    case params[:root]
    when 'source'
      @concepts = Concept::Base.tops.published.with_pref_labels
    when /\d+/
      root_concept = Concept::Base.find(params[:root])
      @concepts = Concept::Base.published.with_pref_labels.includes(:broader_relations).where(Concept::Relation::Base.arel_table[:target_id].eq(root_concept.id)).all
    end
    
    respond_to do |format|
      format.html
      format.json do
        @concepts.map! do |c|
          hsh = {
            :text => c.pref_label.to_s,
            :url  => concept_path(:lang => @active_language, :id => c),
            :id   => c.id
          }
          hsh[:hasChildren] = c.narrower_relations.any?
          hsh
        end
        render :json => @concepts.to_json
      end
    end
  end

end
