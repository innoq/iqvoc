class UMT::CompoundFormContent < ActiveRecord::Base
  
  belongs_to :compound_form, :class_name => "UMT::CompoundForm"
  belongs_to :label

  def temporary_name
    "CompoundFromContent"
  end

  named_scope :published, lambda { |compound_form_id| {
          :joins => :label,
          :conditions => ["(compound_form_contents.compound_form_id = #{compound_form_id} AND labels.published_at IS NOT NULL) OR (compound_form_contents.compound_form_id = #{compound_form_id} AND labels.rev = 1 AND labels.published_at IS NULL)"] }
  }

  named_scope :published_without_initial_versions, lambda { |compound_form_id| {
          :joins => :label,
          :conditions => ["(compound_form_contents.compound_form_id = #{compound_form_id} AND labels.published_at IS NOT NULL)"] }
  }

  named_scope :target_in_edit_mode, lambda {|domain_id|
    { :joins => [:compound_form, :label],
      :include => :label,
      :conditions => "(compound_forms.domain_id = #{domain_id}) AND (labels.locked_by IS NOT NULL)"
    }
  }

end