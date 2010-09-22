class ConceptsController < ApplicationController
  skip_before_filter :require_user
  before_filter { |c| c.authorize! :read, :published_concept }
  
  def index
    respond_to do |format|
      format.json do
        @concepts = Iqvoc::Concept.base_class.all(:joins => :pref_labels, :conditions => ["(labels.value LIKE :query AND concepts.published_at IS NOT NULL) OR (labels.value LIKE :query AND concepts.rev = 1 AND concepts.published_at IS NULL)", {:query => "#{params[:query]}%"}], :group => "labelings.owner_id")
        response = []
        @concepts.each { |concept| response << {:id => concept.id, :name => concept.pref_label.value, :origin => concept.origin, :published => concept.published?}}

        render :json => response
      end
    end
  end

  def show
    @concept = Iqvoc::Concept.base_class.by_origin(params[:id]).published.with_associations.last
    @new_concept_version = Iqvoc::Concept.base_class.by_origin(params[:id]).unpublished.last
    respond_to do |format|

      format.html do
        raise ActiveRecord::RecordNotFound unless @concept
        store_location
      end

      format.rdf

      format.ttl do
        head 404 unless @concept
      end
      
    end
  end
  
end
