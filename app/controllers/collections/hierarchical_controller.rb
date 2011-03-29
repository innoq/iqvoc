class Collections::HierarchicalController < CollectionsController
  skip_before_filter :require_user # XXX: why? (cf. concepts/hierarchical)

  def index
    authorize! :read, Collection::Base

    root = Iqvoc::Collection.base_class.find(params[:root])
    children = root.subcollections

    children.sort! do |a, b|
      a.label.to_s <=> b.label.to_s
    end

    respond_to do |format|
      format.json do
        children.map! do |collection|
          {
            :id => collection.id,
            :url => collection_path(:lang => @active_language, :id => collection),
            :text => CGI.escapeHTML(collection.label.to_s),
            :hasChildren => collection.subcollections.any?
          }
        end
        render :json => children.to_json
      end
    end
  end

end
