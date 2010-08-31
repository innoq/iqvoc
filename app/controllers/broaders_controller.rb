class BroadersController < SemanticRelationsController
  def create
    super
    @owner_concept.broader_relations.push_with_reflection_creation(Broader.new(:target_id => @target_concept.id))
    broader = Broader.find_by_owner_id_and_target_id(@owner_concept.id, @target_concept.id)
    render :json => { :id => broader.id, :origin => @target_concept.origin, :published => @target_concept.published?}.to_json
  rescue Exception => e
    logger.error(e)
    head :internal_server_error
  end

  def destroy
    concept = Concept.new_version(params[:versioned_concept_id]).first
    broader_relation = Broader.find(params[:id])
    raise ActiveRecord::RecordNotFound unless broader_relation
    if concept.broader_relations.destroy_reflection(broader_relation)
      head :ok
    else
      head :internal_server_error
    end
  rescue Exception => e
    logger.error(e)
    if e.class == "ActiveRecord::RecordNotFound".constantize
      render :json => I18n.t("txt.common.association_not_found"), :status => :internal_server_error
    else
      head :internal_server_error
    end
  end
end
