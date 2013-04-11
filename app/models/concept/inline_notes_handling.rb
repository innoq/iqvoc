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
      after_save :process_inline_notes

      attr_writer :inline_notes
    end

    def inline_notes
      @inline_notes ||= {}
    end

    protected

    def process_inline_notes
      self.inline_notes.each do |rdf_type, lang_values|
        self.notes.for_rdf_type(rdf_type).each do |note|
          self.notes.delete(note.destroy)
        end

        lang_values.each do |lang, inline_values|
          lang = nil if lang.to_s == 'none'
          Iqvoc::InlineDataHelper.parse_inline_values(inline_values).each do |value|
            value.squish!
            unless value.blank?
              tokens = {:ObjectLangstringLanguage => lang, :ObjectLangstringString => value, :Predicate => rdf_name}
              self.notes.build_from_parsed_tokens(tokens, :subject_instance => self)
            end
          end
        end
      end

    end
  end
end
