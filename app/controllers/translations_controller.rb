class TranslationsController < LabelRelationsController
  def create
    super
    if @versioned_range_label.present?
      @domain_label.translations << UMT::Translation.new(:range_id => @versioned_range_label.id)
    end
    translation = @domain_label.translations << UMT::Translation.new(:range_id => @range_label.id)
    render :json => { :id => translation.last.id, :origin => @range_label.origin, :published => @range_label.published?}.to_json
    rescue
      head :internal_server_error
  end
end