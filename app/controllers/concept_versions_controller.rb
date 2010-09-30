class ConceptVersionsController < ApplicationController

  def merge
    current_concept = Iqvoc::Concept.base_class.by_origin(params[:origin]).published.last
    new_version = Iqvoc::Concept.base_class.by_origin(params[:origin]).unpublished.last
    raise ActiveRecord::RecordNotFound.new("Couldn't find unpublished concept with origin '#{params[:origin]}'") unless new_version
    authorize! :merge, new_version
    ActiveRecord::Base.transaction do
      if current_concept.blank? || current_concept.destroy
        new_version.publish!
        new_version.unlock!
        if new_version.valid_with_full_validation?
          new_version.save
          begin
            if RdfStore.update(new_version.rdf_uri, concept_url(:id => new_version, :format => :ttl))
              new_version.update_attribute(:rdf_updated_at, 1.seconds.since)
            end
          rescue Exception => e
            handle_virtuoso_exception(e.message)
          end
          flash[:notice] = t("txt.controllers.versioning.published")
          redirect_to concept_path(:lang => @active_language, :id => new_version)
        else
          flash[:error] = t("txt.controllers.versioning.merged_publishing_error")
          redirect_to versioned_concept_path(:id => new_version, :lang => @active_language)
        end
      else
        flash[:error] = t("txt.controllers.versioning.merged_delete_error")
        redirect_to versioned_concept_path(:id => new_version, :lang => @active_language)
      end
    end
  end

  def branch
    current_concept = Iqvoc::Concept.base_class.by_origin(params[:origin]).published.last
    raise ActiveRecord::RecordNotFound.new("Couldn't find published concept with origin '#{params[:origin]}'") unless current_concept
    raise "There is already an unpublished version for Concept '#{params[:origin]}'" if Iqvoc::Concept.base_class.by_origin(params[:origin]).unpublished.last
    authorize! :branch, current_concept
    new_version = nil
    ActiveRecord::Base.transaction do
      new_version = current_concept.branch(current_user)
      new_version.save!
    end
    flash[:notice] = t("txt.controllers.versioning.branched")
    redirect_to edit_versioned_concept_path(:id => new_version, :lang => @active_language, :check_associations_in_editing_mode => true)
  end

  def lock
    new_version = Iqvoc::Concept.base_class.by_origin(params[:origin]).unpublished.last
    raise ActiveRecord::RecordNotFound.new("Couldn't find unpublished concept with origin '#{params[:origin]}'") unless new_version
    raise "Concept with origin '#{params[:origin]}' has already been locked." if new_version.locked?
    authorize! :lock, new_version

    new_version.lock_by_user!(current_user.id)
    new_version.save!
    
    flash[:notice] = t("txt.controllers.versioning.locked")
    redirect_to edit_versioned_concept_path(:id => new_version, :lang => @active_language)
  end

  def unlock
    new_version = Iqvoc::Concept.base_class.by_origin(params[:origin]).unpublished.last
    raise ActiveRecord::RecordNotFound.new("Couldn't find unpublished concept with origin '#{params[:origin]}'") unless new_version
    raise "Concept with origin '#{params[:origin]}' wasn't locked." unless new_version.locked?
    authorize! :unlock, new_version

    new_version.unlock!
    new_version.save!

    flash[:notice] = t("txt.controllers.versioning.unlocked")
    redirect_to versioned_concept_path(:id => new_version, :lang => @active_language)
  end

  def consistency_check
    @concept = Iqvoc::Concept.base_class.by_origin(params[:origin]).unpublished.last
    raise ActiveRecord::RecordNotFound unless @concept
    if @concept.valid_with_full_validation?
      flash[:notice] = t("txt.controllers.versioning.consistency_check_success")
      redirect_to versioned_concept_path(:id => @concept, :lang => @active_language)
    else
      flash[:error] = t("txt.controllers.versioning.consistency_check_error")
      render 'versioned_concepts/edit'
    end
  end

  def to_review
    concept = Iqvoc::Concept.base_class.by_origin(params[:origin]).unpublished.last
    raise ActiveRecord::RecordNotFound unless concept
    concept.to_review!
    concept.save!
    flash[:notice] = t("txt.controllers.versioning.to_review_success")
    redirect_to versioned_concept_path(@active_language, concept)
  end
  
end
