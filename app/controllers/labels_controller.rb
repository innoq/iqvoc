class LabelsController < ApplicationController
  skip_before_filter :require_user
  before_filter { |c| c.authorize!(:read, :published_label) }
  
  def index
    respond_to do |format|
      format.json do
        if params[:alt_label_lang]
          @labels = Iqvoc::Label.base_class.all(:conditions => ["(value LIKE :query AND published_at IS NOT NULL AND language LIKE :language) OR (value LIKE :query AND rev = 1 AND published_at IS NULL AND language LIKE :language)", {:query => "#{params[:query]}%", :language => params[:alt_label_lang]}])
        else
          @labels = Iqvoc::Label.base_class.all(:conditions => ["(value LIKE :query AND published_at IS NOT NULL) OR (value LIKE :query AND rev = 1 AND published_at IS NULL)", {:query => "#{params[:query]}%"}])
        end

        response = []
        @labels.each { |label| response << {:id => label.id, :name => label.value, :origin => label.origin, :published => label.published?} }
        
        render :json => response
      end
    end
  end

  def show
    @label = Label::SKOSXL::Base.current_version(params[:id]).published.with_associations.first
    @new_label_version = Iqvoc::Label.base_class.new_version(params[:id]).first
    respond_to do |format|
      
      format.html do
        raise ActiveRecord::RecordNotFound unless @label
       # @concepts_as_pref_label = @label.concepts_as_pref_label.all(:include => :pref_labels)
       # @concepts_as_alt_label = @label.concepts_as_alt_label.all(:include => :pref_labels)
        @compound_in = Iqvoc::Label.base_class.compound_in(@label).all
        store_location
      end
      
      format.ttl do
        head 404 unless @label
      end
      
    end
  end
end
