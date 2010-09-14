class RelatedController < SemanticRelationsController
  def create
    super
    @owner_concept.related_relations.push_with_reflection_creation(Related.new(:target_id => @target_concept.id))
    related = Related.find_by_owner_id_and_target_id(@owner_concept.id, @target_concept.id)
    render :json => { :id => related.id, :origin => @target_concept.origin, :published => @target_concept.published?}.to_json
    rescue Exception => e
      logger.error(e)
      head :internal_server_error
  end

  def destroy
    concept = Iqvoc::Concept.base_class.new_version(params[:versioned_concept_id]).first
    related_relation = Related.find(params[:id])
    raise ActiveRecord::RecordNotFound unless related_relation
    if concept.related_relations.destroy_reflection(related_relation)
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
