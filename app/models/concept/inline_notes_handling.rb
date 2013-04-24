# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Concept
  module InlineNotesHandling
    extend ActiveSupport::Concern

    included do
      before_validation :process_inline_notes
      after_save :persist_notes

      attr_writer :inline_notes
    end

    # returns a hash of hashes, first-level key being the rdf type, second level key being the note ID
    # ex: inline_notes = {'skos:scopeNote' => {'1' => {'language' => 'en', 'value' => 'Foo', '_delete' => '0'}, ...}, ...}
    def inline_notes(reload = false)
      if reload
        @inline_notes = load_inline_notes
      else
        @inline_notes ||= load_inline_notes
      end
      @inline_notes.each do |key, values|
        if values.is_a? Array
          @inline_notes[key] = {'0' => values.first} # HACK
        end
      end
    end

    protected

    def persist_notes
      self.notes.each &:save
    end

    def load_inline_notes
      Hash.new.with_indifferent_access.tap do |n|
        self.notes.each do |note|
          n[note.rdf_internal_name] ||= Hash.new.with_indifferent_access
          n[note.rdf_internal_name][note.id.to_s] = note.attributes.with_indifferent_access
        end
      end
    end

    def process_inline_notes
      self.inline_notes.each do |rdf_type, notes_attrs|
        self.notes.for_rdf_class(rdf_type).each do |note|
          self.notes.destroy_later(note)
        end

        notes_attrs.each_pair do |id, attrs|
          lang = attrs[:language].to_s == 'none' ? nil : attrs[:language]
          unless attrs[:value].blank? or attrs[:_destroy].to_s == '1'
            tokens = {:ObjectLangstringLanguage => lang, :ObjectLangstringString => attrs[:value], :Predicate => rdf_type}
            self.notes.build_from_parsed_tokens(tokens, :subject_instance => self)
            # TODO: handle annotations and other attributes
          end
        end
      end
    end

  end
end
