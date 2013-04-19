# encoding: UTF-8

module Concept
  module NoteSubtypeExtensions
    extend ActiveSupport::Concern

    included do
      Iqvoc::Concept.note_class_names.each do |klass|
        define_method klass.rdf_internal_name do
          self.for_rdf_class(klass.rdf_internal_name)
        end
      end
    end

  end
end
