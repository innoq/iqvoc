class NarrowersController < SemanticRelationsController
  def create
    super
    @owner_concept.narrower_relations.push_with_reflection_creation(Narrower.new(:target_id => @target_concept.id))
    narrower = Narrower.find_by_owner_id_and_target_id(@owner_concept.id, @target_concept.id)
    render :json => { :id => narrower.id, :origin => @target_concept.origin, :published => @target_concept.published?}.to_json
  rescue Exception => e
    logger.error(e)
    head :internal_server_error
  end

  def destroy
    concept = Iqvoc::Concept.base_class.new_version(params[:versioned_concept_id]).first
    narrower_relation = Narrower.find(params[:id])

    raise ActiveRecord::RecordNotFound unless narrower_relation
    if concept.narrower_relations.destroy_reflection(narrower_relation)
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
