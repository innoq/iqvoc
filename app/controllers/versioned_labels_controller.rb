class VersionedLabelsController < LabelsController
  before_filter(:only => :show) { |c| c.authorize!(:read, :versioned_label) }
  before_filter(:except => :show) { |c| c.authorize!(:write, :versioned_label) }
  
  def show
    @label = Label.get_new_or_initial_version(params[:id])
    raise ActiveRecord::RecordNotFound unless @label

    inflectionals = Inflectional.find_all_by_value(@label.inflectionals.map(&:value))
    # subtract initial and current version from the inflectionals collection
    @inflectionals_labels = Label.find(inflectionals.map(&:label_id)-[Label.current_version(params[:id]).first.id, @label.id])

    respond_to do |format|

      format.html do
        @concepts_as_pref_label = @label.concepts_as_pref_label.all(:include => :pref_labels)
        @concepts_as_alt_label = @label.concepts_as_alt_label.all(:include => :pref_labels)
        @compound_in = Label.compound_in(@label).all
      end

      format.ttl do
        head 404 unless @label
      end

    end
  end

  def new
    @label = !defined?(params[:value]) ? Label.new : Label.new(:value => params[:value])
  end

  def create
    @label = Label.new(params[:label])
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
    @label = Label.get_new_or_initial_version(params[:id])
    raise ActiveRecord::RecordNotFound unless @label
    
    authorize! :continue_editing, @label

    if params[:check_associations_in_editing_mode]
      @association_objects_in_editing_mode = @label.associated_objects_in_editing_mode
    end

    @pref_labelings = PrefLabeling.by_label(@label).all(:include => {:owner => :pref_labels}).sort
    @alt_labelings = AltLabeling.by_label(@label).all(:include => {:owner => :pref_labels}).sort
    @compound_in = Label.compound_in(@label).all.sort

    [:definitions, :editorial_notes, :umt_source_notes, :umt_usage_notes, :umt_change_notes].each do |relation|
      @label.send(relation).build if @label.send(relation).empty?
    end
  end

  def update
    @label = Label.get_new_or_initial_version(params[:id])
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
    @new_label = Label.get_new_or_initial_version(params[:id])
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
