class LabelsController < ApplicationController
  skip_before_filter :require_user
  before_filter { |c| c.authorize!(:read, :published_label) }
  
  def index
    respond_to do |format|
      format.json do
        if params[:language] # TODO Label::Base should perhaps be replaced by the label_class used in the labeling (s. MyLabeling.label_class). But then the relation class must be passed to this action (max 2 lines of code :-) )
         # FIXME this querys suck!!!
          @labels = Label::Base.all(:conditions => ["(value LIKE :query AND published_at IS NOT NULL AND language LIKE :language) OR (value LIKE :query AND rev = 1 AND published_at IS NULL AND language LIKE :language)", {:query => "#{params[:query]}%", :language => params[:language]}])
        else
          @labels = Label::Base.all(:conditions => ["(value LIKE :query AND published_at IS NOT NULL) OR (value LIKE :query AND rev = 1 AND published_at IS NULL)", {:query => "#{params[:query]}%"}])
        end

        response = []
        @labels.each { |label| response << {:name => label.value, :origin => label.origin, :published => label.published?} }
        
        render :json => response
      end
    end
  end

  def show
    @label = Iqvoc::XLLabel.base_class.by_origin(params[:id]).published.with_associations.first
    @new_label_version = Iqvoc::XLLabel.base_class.by_origin(params[:id]).unpublished.first
    respond_to do |format|
      
      format.html do
        raise ActiveRecord::RecordNotFound unless @label
       # @concepts_as_pref_label = @label.concepts_as_pref_label.all(:include => :pref_labels)
       # @concepts_as_alt_label = @label.concepts_as_alt_label.all(:include => :pref_labels)
        @compound_in = @label.reverse_compound_forms.published.includes(:domain).map(&:domain)
        store_location
      end
      
      format.ttl do
        head 404 unless @label
      end
      
    end
  end
end
