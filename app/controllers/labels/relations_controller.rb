class Labels::RelationsController < ApplicationController
  def create
    label = load_label
    relation_class = load_relation_class

    target_label = Iqvoc::XLLabel::base_class.by_origin(params[:origin]).editor_selectable.last
    raise ActiveRecord::RecordNotFound unless target_label
    target_labels_new_version = Iqvoc::XLLabel::base_class.by_origin(params[:origin]).unpublished.last

    ActiveRecord::Base.transaction do
      label.send(relation_class.name.to_relation_name).find_or_create_by_range_id(target_label.id)
      if target_labels_new_version and target_labels_new_version.rev > target_label.rev
        label.send(relation_class.name.to_relation_name).find_or_create_by_range_id(target_labels_new_version.id)
      end
    end

    render :json => { :origin => target_label.origin, :published => target_label.published?}.to_json

  end

  def destroy
    label = load_label
    relation_class = load_relation_class

    target_labels = [Iqvoc::XLLabel.base_class.by_origin(params[:origin]).editor_selectable.last].compact
    raise ActiveRecord::RecordNotFound unless target_labels.count > 0
    target_labels_new_version = Iqvoc::XLLabel.base_class.by_origin(params[:origin]).unpublished.last
    target_labels << target_labels_new_version if target_labels_new_version and target_labels_new_version.rev > target_labels.first.rev

    ActiveRecord::Base.transaction do
      target_labels.each do |target_label|
        label.send(relation_class.name.to_relation_name).by_range(target_label).each do |relation|
          relation.destroy
        end
      end
    end

    head :ok
  end

  protected

  def load_label
    label = Iqvoc::XLLabel::base_class.by_origin(params[:label_id]).unpublished.last
    raise ActiveRecord::RecordNotFound unless label
    label
  end

  def load_relation_class
    raise "'#{params[:labeling_class]}' is not a valid / configured relation class!" unless Iqvoc::XLLabel.relation_class_names.include?(params[:relation_class])
    params[:relation_class].constantize
  end


end