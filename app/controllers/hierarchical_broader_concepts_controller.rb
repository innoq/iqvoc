class HierarchicalBroaderConceptsController < HierarchicalConceptsController
  def index
    case params[:root]
      when 'source'
        @concepts = Concept.published.broader_tops
      when /\d+/
        @concepts = Concept.find(params[:root]).broader.published.with_pref_labels.all
    end

     respond_to do |format|
      format.html { store_location }
      format.json do
        @concepts.map! do |c|
          hsh = {
            :text => c.pref_label.to_s,
            :url  => language_concept_path(@active_language, c),
            :id   => c.id
          }
          hsh[:hasChildren] = c.broader.any?
          hsh
        end
        render :json => @concepts.to_json
      end
    end

  end
end