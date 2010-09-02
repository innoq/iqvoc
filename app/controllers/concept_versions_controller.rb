class ConceptVersionsController < ApplicationController
  #Merges the current and the new concept vesion
  def merge
    current_concept = Concept.current_version(params[:origin]).published.first
    new_version = Concept.get_new_or_initial_version(params[:origin])
    raise ActiveRecord::RecordNotFound unless new_version
    #    begin
    ActiveRecord::Base.transaction do
      if (current_concept.present? ? current_concept.collect_first_level_associated_objects.each(&:destroy) && (current_concept.delete) : true)
        new_version.prepare_for_merging
        if new_version.valid_with_full_validation?
          new_version.save
          begin
            if RdfStore.update(new_version.rdf_uri, concept_url(new_version, :format => :ttl))
              new_version.update_attribute(:rdf_updated_at, 1.seconds.since)
            end
          rescue Exception => e
            handle_virtuoso_exception(e.message)
          end
          flash[:notice] = t("txt.controllers.versioning.published")
          redirect_to concept_path(:lang => @active_language, :id => new_version)
        else
          logger.debug new_version.errors.inspect
          flash[:error] = t("txt.controllers.versioning.merged_publishing_error")
          redirect_to versioned_concept_path(:id => new_version, :lang => @active_language)
        end
      else
        flash[:error] = t("txt.controllers.versioning.merged_delete_error")
        redirect_to versioned_concept_path(:id => new_version, :lang => @active_language)
      end
    end

    #    rescue Exception => e
    #      logger.error(e)
    #      @concept = new_version
    #      flash[:error] = t("txt.controllers.versioning.merged_publishing_error")
    #      render :template => "versioned_concepts/edit"
    #    end
  end

  #Creates a new Version of a Concept
  def branch
    current_concept = Concept.current_version(params[:origin]).first
    new_version = Concept.new_version(params[:origin]).first
    if new_version.blank?
      new_version = current_concept.clone :include => Concept.associations_for_versioning
      new_version.prepare_for_branching(current_user.id)
      if new_version.save
        flash[:notice] = t("txt.controllers.versioning.merged")
        redirect_to edit_versioned_concept_path(:id => new_version, :lang => @active_language, :check_associations_in_editing_mode => true)
      end
    else
      flash[:error] = t("txt.controllers.versioning.branch_error")
      redirect_to versioned_concept_path(:id => new_version, :lang => @active_language)
    end
  end

  #Locks the Concept
  def lock
    current_version = Concept.current_version(params[:origin]).first
    new_version = Concept.get_new_or_initial_version(params[:origin])
    if !new_version.blank?
      if !new_version.locked?
        new_version.lock_by_user!(current_user.id)
        if new_version.save
          flash[:notice] = t("txt.controllers.versioning.locked")
          flash[:notice] = t("txt.controllers.versioning.locked")
          redirect_to edit_versioned_concept_path(:id => new_version, :lang => @active_language)
        end
      else
        flash[:error] = t("txt.controllers.versioning.lock_error")
        redirect_to versioned_concept_path(:id => new_version, :lang => @active_language)
      end

    else
      flash[:error] = t("txt.controllers.versioning.new_version_blank_error")
      redirect_to concept_path(:lang => @active_language, :id => current_version)
    end
  end

  #Unlocks the Concept
  def unlock
    current_version = Concept.current_version(params[:origin]).first
    new_version = Concept.get_new_or_initial_version(params[:origin])
    if !new_version.blank?
      if new_version.locked?
        authorize! :unlock, new_version
        new_version.unlock!
        if new_version.save
          flash[:notice] = t("txt.controllers.versioning.unlocked")
          redirect_to versioned_concept_path(:id => new_version, :lang => @active_language)
        end
      else
        flash[:error] = t("txt.controllers.versioning.unlock_error")
        redirect_to versioned_concept_path(:id => new_version, :lang => @active_language)
      end

    else
      flash[:error] = t("txt.controllers.versioning.new_version_blank_error")
      redirect_to concept_path(:lang => @active_language, :id => current_version)
    end
  end

  def consistency_check
    @concept = Concept.get_new_or_initial_version(params[:origin])
    raise ActiveRecord::RecordNotFound unless @concept
    if @concept.valid_with_full_validation?
      flash[:notice] = t("txt.controllers.versioning.consistency_check_success")
      redirect_to versioned_concept_path(@active_language, @concept)
    else
      flash[:error] = t("txt.controllers.versioning.consistency_check_error")
      render :template => "versioned_concepts/edit"
    end
  end

  def to_review
    @concept = Concept.get_new_or_initial_version(params[:origin])
    raise ActiveRecord::RecordNotFound unless @concept
    @concept.to_review!
    if @concept.save
      flash[:notice] = t("txt.controllers.versioning.to_review_success")
      redirect_to versioned_concept_path(@active_language, @concept)
    else
      flash[:error] = t("txt.controllers.versioning.to_review_error")
      redirect_to versioned_concept_path(@active_language, @concept)
    end
  end
end
