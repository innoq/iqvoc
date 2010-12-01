class Concepts::HierarchicalController < ConceptsController
  skip_before_filter :require_user
  
  def index
    authorize! :read, Concept::Base

    scope = if params[:published] == '0'
      Concept::Base.editor_selectable
    else
      Concept::Base.published
    end
    
    # if params[:broader] is given, the action is handling the reversed tree
    @concepts = case params[:root]
    when /\d+/
      root_concept = Concept::Base.find(params[:root])
      if params[:broader]
        scope.
          includes(:narrower_relations, :broader_relations). # D A N G E R: the order matters!!! See the following where
        where(Concept::Relation::Base.arel_table[:target_id].eq(root_concept.id))
      else
        scope.
          includes(:broader_relations, :narrower_relations). # D A N G E R: the order matters!!! See the following where
        where(Concept::Relation::Base.arel_table[:target_id].eq(root_concept.id))
      end
    else
      if params[:broader]
        scope.broader_tops.includes(:broader_relations)
      else
        scope.tops.includes(:narrower_relations)
      end
    end
    # When in single query mode, AR handles ALL includes to be loaded by that
    # one query. We don't want that! So let's do it manually :-)
    Concept::Base.send(:preload_associations, @concepts, Iqvoc::Concept.base_class.default_includes + [:pref_labels])
    
    respond_to do |format|
      format.html
      format.json do
        @concepts.map! do |c|
          hsh = {
            :text => CGI.escapeHTML(c.pref_label(params[:pref_label_lang]).to_s),
            :url  => concept_path(:lang => @active_language, :id => c),
            :id   => c.id
          }
          hsh[:additionalText] = " (#{c.additional_info})" if c.additional_info.present?
          hsh[:hasChildren] = params[:broader] ? c.broader_relations.any? : c.narrower_relations.any?
          hsh
        end
        render :json => @concepts.to_json
      end
    end
  end

end
