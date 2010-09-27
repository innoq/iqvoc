# FIXME even when VersionedConceptsController inherits ConceptsController there
# is nearly no object orientation in here. nearly every line is copied!
class VersionedLabelsController < LabelsController
  before_filter(:only => :show) { |c| c.authorize!(:read, :versioned_label) }
  before_filter(:except => :show) { |c| c.authorize!(:write, :versioned_label) }
  
  def show
    @label = Iqvoc::XLLabel.base_class.by_origin(params[:id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless @label

    respond_to do |format|

      format.html do
      end

      format.ttl do
        head 404 unless @label
      end

    end
  end

  def new
    @label = !defined?(params[:value]) ? Iqvoc::XLLabel.base_class.new : Iqvoc::XLLabel.base_class.new(:value => params[:value])
  end

  def create
    @label = Iqvoc::XLLabel.base_class.new(params[:label])
    label_value = params[:label][:value]
    if @label.valid?
      origin = OriginMapping.new
      @label.origin = origin.merge(params[:label][:value])
      if @label.save
        flash[:notice] = I18n.t("txt.controllers.versioned_label.success")
        redirect_to versioned_label_path(:id => @label.origin, :lang => @active_language)
      else
        flash[:error] = I18n.t("txt.controllers.versioned_label.error")
        render :new
      end
    else
      flash[:error] = I18n.t("txt.controllers.versioned_label.error")
      render :new
    end
  end

  def edit
    @label = Iqvoc::XLLabel.base_class.by_origin(params[:id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless @label
    
    authorize! :continue_editing, @label

    if params[:check_associations_in_editing_mode]
      @association_objects_in_editing_mode = @label.associated_objects_in_editing_mode
    end

    # @pref_labelings = PrefLabeling.by_label(@label).all(:include => {:owner => :pref_labels}).sort
    # @alt_labelings = AltLabeling.by_label(@label).all(:include => {:owner => :pref_labels}).sort

    Iqvoc::XLLabel.note_class_names.each do |note_class_name|
      @label.send(note_class_name.to_relation_name).build if @label.send(note_class_name.to_relation_name).empty?
    end
  end

  def update
    @label = Iqvoc::XLLabel.base_class.by_origin(params[:id]).unpublished.last
    respond_to do |format|
      format.html do
        raise ActiveRecord::RecordNotFound unless @label
        if @label.update_attributes(params[:label])
          flash[:notice] = I18n.t("txt.controllers.versioned_label.update_success")
          redirect_to versioned_label_path(:id => @label, :lang => @active_language)
        else
          flash[:error] = I18n.t("txt.controllers.versioned_label.update_error")
          render :action => :edit
        end
      end
    end
  end

  def destroy
    @new_label = Iqvoc::XLLabel.base_class.by_origin(params[:id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless @new_label
    if (@new_label.collect_first_level_associated_objects.each(&:destroy)) && (@new_label.delete)
      flash[:notice] = I18n.t("txt.controllers.label_versions.delete")
      redirect_to dashboard_path(:lang => @active_language)
    else
      flash[:notice] = I18n.t("txt.controllers.label_versions.delete_error")
      redirect_to versioned_label_path(:id => @new_label, :lang => @active_language)
    end
  end
end
