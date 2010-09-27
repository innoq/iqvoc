# FIXME even when VersionedConceptsController inherits ConceptsController there
# is nearly no object orientation in here. nearly every line is copied!
class VersionedConceptsController < ConceptsController

  def show
    @concept = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless @concept
    authorize! :read, @concept
    respond_to do |format|
      format.html do
        raise ActiveRecord::RecordNotFound unless @concept
      end
    end
  end

  def new
    authorize! :create, Iqvoc::Concept.base_class
    @concept = Iqvoc::Concept.base_class.new

    Iqvoc::Concept.note_class_names.each do |note_class_name|
      @concept.send(note_class_name.to_relation_name).build if @concept.send(note_class_name.to_relation_name).empty?
    end
  end

  def create
    authorize! :create, Iqvoc::Concept.base_class
    @concept = Iqvoc::Concept.base_class.new(params[:concept])
    if @concept.generate_origin
      if @concept.save
        flash[:notice] = I18n.t("txt.controllers.versioned_concept.success")
        redirect_to versioned_concept_path(:id => @concept.origin, :lang => @active_language)
      else
        flash[:error] = I18n.t("txt.controllers.versioned_concept.error")
        render :new
      end
    else
      flash[:error] = I18n.t("txt.controllers.versioned_concept.error")
      render :new
    end
  end

  def edit
    @concept = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless @concept

    authorize! :update, @concept

    if params[:check_associations_in_editing_mode]
      @association_objects_in_editing_mode = @concept.associated_objects_in_editing_mode
    end

    Iqvoc::Concept.note_class_names.each do |note_class_name|
      @concept.send(note_class_name.to_relation_name).build if @concept.send(note_class_name.to_relation_name).empty?
    end
  end

  def update
    @concept = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless @concept
    authorize! :update, @concept

    if @concept.update_attributes(params[:concept])
      flash[:notice] = I18n.t("txt.controllers.versioned_concept.update_success")
      redirect_to versioned_concept_path(:id => @concept, :lang => @active_language)
    else
      flash[:error] = I18n.t("txt.controllers.versioned_concept.update_error")
      render :action => :edit
    end
  end

  def destroy
    @new_concept = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless @new_concept
    authorize! :destroy, @concept
    if @new_concept.destroy
      flash[:notice] = I18n.t("txt.controllers.concept_versions.delete")
      redirect_to dashboard_path(:lang => @active_language)
    else
      flash[:notice] = I18n.t("txt.controllers.concept_versions.delete_error")
      redirect_to versioned_label_path(:id => @new_concept, :lang => @active_language)
    end
  end

end