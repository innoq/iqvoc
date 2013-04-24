# encoding: UTF-8

module Concept
  module LabelingSubtypeExtensions

    def each_configured_class(&block)
      Iqvoc::Concept.labeling_class_names.each do |name, languages|
        yield name.constantize
      end
    end

  end
end
