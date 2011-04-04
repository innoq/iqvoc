class LabelsController < ApplicationController
  skip_before_filter :require_user

  def index
    authorize! :read, Iqvoc::XLLabel.base_class
    respond_to do |format|
      format.json do
        scope = Label::Base.by_query_value("#{params[:query]}%")
        if params[:language] # XXX: isn't this always the case; language is required, supplied via route!?
          # TODO
          # Label::Base should perhaps be replaced by the label_class used in the labeling
          # (s. MyLabeling.label_class). But then the relation class must be passed
          # to this action (max 2 lines of code :-) )
          scope = scope.by_language(params[:language])
        end
        @labels = scope.published.order("LOWER(value)").all

        response = []
        @labels.each { |label| response << label_widget_data(label) }

        render :json => response
      end
    end
  end

  def show
    if params[:published] == '1' || !params[:published]
      published = true
      @label = Iqvoc::XLLabel.base_class.by_origin(params[:id]).published.last
      @new_label_version = Iqvoc::XLLabel.base_class.by_origin(params[:id]).unpublished.last
    elsif params[:published] == '0'
      published = false
      @label = Iqvoc::XLLabel.base_class.by_origin(params[:id]).unpublished.last
    end

    raise ActiveRecord::RecordNotFound unless @label
    authorize! :read, @label

    respond_to do |format|
      format.html do
        published ? render('show_published') : render('show_unpublished')
      end
      format.ttl
    end
  end

  def new
    authorize! :create, Iqvoc::XLLabel.base_class
    raise "You have to specify a language parameter!" if params[:language].blank?
    data = {:language => params[:language]}
    data.merge(:value => params[:value]) if params[:value]
    @label = Iqvoc::XLLabel.base_class.new(data)
  end

  def create
    authorize! :create, Iqvoc::XLLabel.base_class
    @label = Iqvoc::XLLabel.base_class.new(params[:label])
    if @label.valid?
      @label.origin = OriginMapping.merge(@label.value)
      if @label.save
        flash[:notice] = I18n.t("txt.controllers.versioned_label.success")
        redirect_to label_path(:published => 0, :id => @label.origin, :lang => @active_language)
      else
        flash.now[:error] = I18n.t("txt.controllers.versioned_label.error")
        render :new
      end
    else
      flash.now[:error] = I18n.t("txt.controllers.versioned_label.error")
      render :new
    end
  end

  def edit
    @label = Iqvoc::XLLabel.base_class.by_origin(params[:id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless @label
    authorize! :update, @label

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
    raise ActiveRecord::RecordNotFound unless @label
    authorize! :update, @label

    respond_to do |format|
      format.html do
        raise ActiveRecord::RecordNotFound unless @label
        if @label.update_attributes(params[:label])
          flash[:notice] = I18n.t("txt.controllers.versioned_label.update_success")
          redirect_to label_path(:published => 0, :id => @label, :lang => @active_language)
        else
          flash.now[:error] = I18n.t("txt.controllers.versioned_label.update_error")
          render :action => :edit
        end
      end
    end
  end

  def destroy
    @new_label = Iqvoc::XLLabel.base_class.by_origin(params[:id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless @new_label
    authorize! :destroy, @new_label

    if @new_label.destroy
      flash[:notice] = I18n.t("txt.controllers.label_versions.delete")
      redirect_to dashboard_path(:lang => @active_language)
    else
      flash[:notice] = I18n.t("txt.controllers.label_versions.delete_error")
      redirect_to label_path(:published => 0, :id => @new_label, :lang => @active_language)
    end
  end
end
