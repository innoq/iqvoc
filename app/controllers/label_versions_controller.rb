class LabelVersionsController < ApplicationController
  # Merges the current and the new label version
  def merge
    current_label = Iqvoc::Label.base_class.current_version(params[:origin]).published.first
    new_version = Iqvoc::Label.base_class.get_new_or_initial_version(params[:origin])
    raise ActiveRecord::RecordNotFound unless new_version
    
    if (current_label.present? ? current_label.collect_first_level_associated_objects.each(&:destroy) && (current_label.delete) : true)
      new_version.prepare_for_merging
      if new_version.valid_with_full_validation?
        new_version.save
        begin
          if RdfStore.update(new_version.rdf_uri, label_url(:id => new_version, :format => :ttl))
            new_version.update_attribute(:rdf_updated_at, 1.seconds.since)
          end
        rescue Exception => e
          handle_virtuoso_exception(e.message)
        end
        if new_version.has_concept_or_label_relations?
          flash[:notice] = t("txt.controllers.versioning.published")
          redirect_to label_path(:lang => @active_language, :id => new_version)
        else
          flash[:error] = t("txt.controllers.versioning.published_with_warning")
          redirect_to label_path(:lang => @active_language, :id => new_version)
        end
      else
        flash[:error] = t("txt.controllers.versioning.merged_publishing_error")
        redirect_to versioned_label_path(:id => new_version, :lang => @active_language)
      end
    else
      flash[:error] = t("txt.controllers.versioning.merged_delete_error")
      redirect_to versioned_label_path(:id => new_version, :lang => @active_language)
    end
  end

  #Creates a new Version of a Label
  def branch
    current_label = Iqvoc::Label.base_class.current_version(params[:origin]).first
    new_version = Iqvoc::Label.base_class.new_version(params[:origin]).first
    if new_version.blank?
      new_version = current_label.clone :include => Iqvoc::Label.base_class.associations_for_versioning
      new_version.prepare_for_branching(current_user.id)
      if new_version.save
        flash[:notice] = t("txt.controllers.versioning.merged")
        redirect_to edit_versioned_label_path(:id => new_version, :lang => @active_language, :check_associations_in_editing_mode => true)
      end
    else
      flash[:error] = t("txt.controllers.versioning.branch_error")
      redirect_to versioned_label_path(:id => new_version, :lang => @active_language)
    end
  end

  #Locks the label
  def lock
    current_version = Iqvoc::Label.base_class.current_version(params[:origin]).first
    new_version = Iqvoc::Label.base_class.get_new_or_initial_version(params[:origin])
    if !new_version.blank?
      if !new_version.locked?
        new_version.lock_by_user!(current_user.id)
        if new_version.save
          flash[:notice] = t("txt.controllers.versioning.locked")
          redirect_to edit_versioned_label_path(:id => new_version, :lang => @active_language)
        end
      else
        flash[:error] = t("txt.controllers.versioning.lock_error")
        redirect_to versioned_label_path(:id => new_version, :lang => @active_language)
      end

    else
      flash[:error] = t("txt.controllers.versioning.new_version_blank_error")
      redirect_to label_path(:lang => @active_language, :id => current_version)
    end
  end

  #Unlocks the label
  def unlock
    current_version = Iqvoc::Label.base_class.current_version(params[:origin]).first
    new_version = Iqvoc::Label.base_class.get_new_or_initial_version(params[:origin])
    if !new_version.blank?
      if new_version.locked?
        authorize! :unlock, new_version
        new_version.unlock!
        if new_version.save
          flash[:notice] = t("txt.controllers.versioning.unlocked")
          redirect_to versioned_label_path(:id => new_version, :lang => @active_language)
        end
      else
        flash[:error] = t("txt.controllers.versioning.unlock_error")
        redirect_to versioned_label_path(:id => new_version, :lang => @active_language)
      end

    else
      flash[:error] = t("txt.controllers.versioning.new_version_blank_error")
      redirect_to label_path(:lang => @active_language, :id => current_version)
    end
  end

  def consistency_check
    @label = Iqvoc::Label.base_class.get_new_or_initial_version(params[:origin])
    raise ActiveRecord::RecordNotFound unless @label
    if @label.valid_with_full_validation?
      if @label.has_concept_or_label_relations?
        flash[:notice] = t("txt.controllers.versioning.consistency_check_success")
        redirect_to versioned_label_path(@active_language, @label)
      else
        flash[:error] = t("txt.controllers.versioning.consistency_check_success_with_warning")
        redirect_to versioned_label_path(@active_language, @label)
      end
    else
      @concepts_as_pref_label = @label.concepts_as_pref_label.all(:include => :pref_labels)
      @concepts_as_alt_label = @label.concepts_as_alt_label.all(:include => :pref_labels)
      @compound_in = Iqvoc::Label.base_class.compound_in(@label).all
      flash[:error] = t("txt.controllers.versioning.consistency_check_error")
      render :template => "versioned_labels/edit"
    end
  end

  def to_review
    @label = Iqvoc::Label.base_class.get_new_or_initial_version(params[:origin])
    raise ActiveRecord::RecordNotFound unless @label
    @label.to_review!
    if @label.save
      flash[:notice] = t("txt.controllers.versioning.to_review_success")
      redirect_to versioned_label_path(@active_language, @label)
    else
      flash[:error] = t("txt.controllers.versioning.to_review_error")
      redirect_to versioned_label_path(@active_language, @label)
    end
  end
  
end
