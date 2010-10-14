class Concepts::HierarchicalController < ConceptsController
  skip_before_filter :require_user
  
  def index
    authorize! :read, Concept::Base
    
    # if params[:broader] is given, the action is handling the reversed tree
    case params[:root]
    when 'source'
      @concepts = params[:broader] ? 
        Concept::Base.broader_tops.published.with_pref_labels :
        Concept::Base.tops.published.with_pref_labels
    when /\d+/
      root_concept = Concept::Base.find(params[:root])
      @concepts = params[:broader] ? 
        Concept::Base.published.
                      with_pref_labels.
                      includes(:narrower_relations, :broader_relations). # D A N G E R: the order matters!!! See the following where
                      where(Concept::Relation::Base.arel_table[:target_id].eq(root_concept.id)).
                      all :
        Concept::Base.published.
                      with_pref_labels.
                      includes(:broader_relations, :narrower_relations). # D A N G E R: the order matters!!! See the following where
                      where(Concept::Relation::Base.arel_table[:target_id].eq(root_concept.id)).
                      all
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
          hsh[:hasChildren] = params[:broader] ? c.broader_relations.any? : c.narrower_relations.any?
          hsh
        end
        render :json => @concepts.to_json
      end
    end
  end

end
