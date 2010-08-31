class PrefLabelingsController < LabelingsController
  def create
    super
    if @versioned_target_label.present?
      @owner_concept.pref_labelings << PrefLabeling.new(:target_id => @versioned_target_label.id)
    end
    @owner_concept.pref_labelings << PrefLabeling.new(:target_id => @target_label.id)
    pref_label = PrefLabeling.find(:first, :conditions => {:owner_id => @owner_concept.id, :target_id => @target_label.id})
    render :json => { :id => pref_label.id, :origin => @target_label.origin, :published => @target_label.published?}.to_json
  rescue
    head :internal_server_error
  end
end