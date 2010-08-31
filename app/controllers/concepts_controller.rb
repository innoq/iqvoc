class ConceptsController < ApplicationController
  skip_before_filter :require_user
  before_filter { |c| c.authorize! :read, :published_concept }
  
  def index
    respond_to do |format|
      format.json do
        @concepts = Concept.all(:joins => :pref_labels, :conditions => ["(labels.value LIKE :query AND concepts.published_at IS NOT NULL) OR (labels.value LIKE :query AND concepts.rev = 1 AND concepts.published_at IS NULL)", {:query => "#{params[:query]}%"}], :group => "labelings.owner_id")
        response = []
        @concepts.each { |concept| response << {:id => concept.id, :name => concept.pref_label.value, :origin => concept.origin, :published => concept.published?}}

        render :json => response
      end
    end
  end

  def show
    @concept = Concept.current_version(params[:id]).published.with_associations.first
    @new_concept_version = Concept.new_version(params[:id]).with_associations.first
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

  # Bug im Firefox Tabulator Add-on: der setzt keine Priorität für RDF
  # Wenn man im Tabulator also auf einen Link klickt schickt er blöderweise
  # Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
  # Ihm ist also egal ob xml oder html (gleiche Priorität von 0.9)
  # Rails liefert dann in diesem Fall html aus.
  # Dieses unser Verhalten wäre korrekt, aber blöd bei einer Präsentation
  # mit Tabulator
  # Ich baue also einen Hack ein, der RDF bevorzugt.
  def show_non_informational
    # Man achte auf 2 Blöcke statt einem.
    # 'and return' ist nötig damit es eh ... funktioniert.
    respond_to do |format|
      format.xml  { redirect_to concept_url(@concept, :format => :rdf) }
      format.rdf  { redirect_to concept_url(@concept, :format => :rdf) }
      format.html { redirect_to concept_url(@concept, :format => :html) }
    end
  end
  
end
