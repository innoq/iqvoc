class AltLabelingsController < LabelingsController

  def create
    super
    if @versioned_target_label.present?
      @owner_concept.alt_labelings << AltLabeling.new(:target_id => @versioned_target_label.id)
    end
    @owner_concept.alt_labelings << AltLabeling.new(:target_id => @target_label.id)
    alt_label = AltLabeling.find(:first, :conditions => {:owner_id => @owner_concept.id, :target_id => @target_label.id})
    render :json => { :id => alt_label.id, :origin => @target_label.origin, :published => @target_label.published?}.to_json
  rescue
    head :internal_server_error
  end

end