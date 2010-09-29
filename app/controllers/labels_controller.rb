class LabelsController < ApplicationController
  skip_before_filter :require_user
  
  def index
    authorize! :read, Iqvoc::XLLabel.base_class
    respond_to do |format|
      format.json do
        if params[:language] 
          # TODO 
          # Label::Base should perhaps be replaced by the label_class used in the labeling 
          # (s. MyLabeling.label_class). But then the relation class must be passed 
          # to this action (max 2 lines of code :-) )
          @labels = Label::Base.by_query_value(params[:query]).by_language(params[:language]).published.all
        else
          @labels = Label::Base.by_query_value(params[:query]).published.all
        end

        response = []
        @labels.each { |label| response << {:name => label.value, :origin => label.origin, :published => label.published?} }
        
        render :json => response
      end
    end
  end

  def show
    @label = Iqvoc::XLLabel.base_class.by_origin(params[:id]).published.with_associations.first
    raise ActiveRecord::RecordNotFound unless @label
    authorize! :read, @label
    @new_label_version = Iqvoc::XLLabel.base_class.by_origin(params[:id]).unpublished.first
    respond_to do |format|
      
      format.html do
        raise ActiveRecord::RecordNotFound unless @label
        # @concepts_as_pref_label = @label.concepts_as_pref_label.all(:include => :pref_labels)
        # @concepts_as_alt_label = @label.concepts_as_alt_label.all(:include => :pref_labels)
        store_location
      end
      
      format.ttl do
        head 404 unless @label
      end
      
    end
  end
end
