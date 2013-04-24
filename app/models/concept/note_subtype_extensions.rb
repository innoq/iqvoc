# encoding: UTF-8

module Concept
  module NoteSubtypeExtensions

    def build_new_instance_for_empty_note_classes!
      self.each_configured_class do |klass|
        load_target << klass.new if self.for_class(klass).empty?
      end
    end

    def each_configured_class(&block)
      Iqvoc::Concept.note_class_names.each do |name, languages|
        yield name.constantize
      end
    end

  end
end
