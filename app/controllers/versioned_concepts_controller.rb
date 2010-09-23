# FIXME even when VersionedConceptsController inherits ConceptsController there
# is nearly no object orientation in here. nearly every line is copied!
class VersionedConceptsController < ConceptsController
  before_filter(:only => :show) { |c| c.authorize!(:read, :versioned_label) }
  before_filter(:except => :show) { |c| c.authorize!(:write, :versioned_label) }

  def show
    @concept = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last
    respond_to do |format|
      format.html do
        raise ActiveRecord::RecordNotFound unless @concept
      end
    end
  end

  def new
    @concept = Iqvoc::Concept.base_class.new

    [:definitions, :editorial_notes, :umt_source_notes, :umt_usage_notes, :umt_change_notes, :close_matches].each do |relation|
      @concept.send(relation).build if @concept.send(relation).empty?
    end
  end

  def create
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

    authorize! :continue_editing, @concept

    if params[:check_associations_in_editing_mode]
      @association_objects_in_editing_mode = @concept.associated_objects_in_editing_mode
    end

    # FIXME: This must be fixed later when it is clear how to inster relations in update and create
    #[:definitions, :editorial_notes, :umt_source_notes, :umt_usage_notes, :umt_change_notes, :close_matches].each do |relation|
    #  @concept.send(relation).build if @concept.send(relation).empty?
    #end
  end

  def update
    @concept = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last

    raise ActiveRecord::RecordNotFound unless @concept
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
    if (@new_concept.collect_first_level_associated_objects.each(&:destroy)) && (@new_concept.delete)
      flash[:notice] = I18n.t("txt.controllers.concept_versions.delete")
      redirect_to dashboard_path(:lang => @active_language)
    else
      flash[:notice] = I18n.t("txt.controllers.concept_versions.delete_error")
      redirect_to versioned_label_path(:id => @new_concept, :lang => @active_language)
    end
  end

end