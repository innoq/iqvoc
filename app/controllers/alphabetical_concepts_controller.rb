class AlphabeticalConceptsController < ConceptsController
  skip_before_filter :require_user
  
  def index    
    @alphas = [
      (0..9).to_a,
      ('A'..'Z').to_a,
      '['
    ].flatten
    
    @concepts = Concept.alphabetical(params[:letter]).published.paginate(:page => params[:page], :per_page => 40)
    
    respond_to do |format|
      format.html { store_location }
    end
  end

end
