# FIXME: => AlphabeticalConceptsController -> Concepts::AlphabeticalController
class AlphabeticalConceptsController < ConceptsController
  skip_before_filter :require_user
  
  def index    
    @alphas = 
      ('A'..'Z').to_a +
      (0..9).to_a +
      ['[']
    
    @pref_labelings = Iqvoc::Concept.pref_labeling_class.
      label_published.
      concept_published.
      label_begins_with(params[:letter]).
      by_label_language(@active_language).
      includes(:target). 
      order("LOWER(#{Label::Base.table_name}.value)").
      paginate(:page => params[:page], :per_page => 40)
    
    respond_to do |format|
      format.html { store_location }
    end
  end

end
