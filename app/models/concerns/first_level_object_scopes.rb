module FirstLevelObjectScopes
  extend ActiveSupport::Concern

  module ClassMethods
    def ordered_by_pref_label
      includes(:pref_labels).order('labels.value ASC')
    end
  end
end
