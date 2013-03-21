# encoding: UTF-8

module Concept
  module LabelingSubtypeExtensions
#     extend Concept::TypedHasManyExtension

    protected

    def load_association_if_empty
      if proxy_association.target.empty?
        proxy_association.target = proxy_association.owner.labelings.includes(:target).all
      end
    end

  end
end
