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
  module InlineLabelingsHandling
    extend ActiveSupport::Concern

    included do
      before_validation :process_inline_labelings
    end

    def inline_labelings=(hash)
      @inline_labelings = hash

      @inline_labelings.each do |relation_name, labels_by_lang|
        # if `language` is `nil`, the respective HTML form field returns an array
        # instead of a hash (`<input name=bla[labeling_class][]>`)
        if labels_by_lang.is_a?(Array)
          @inline_labelings[relation_name] = { nil => labels_by_lang.first }
        end
      end
      @inline_labelings
    end

    def inline_labelings(relation_name, language)
      (@inline_labelings && @inline_labelings[relation_name] &&
          @inline_labelings[relation_name][language]) ||
          Iqvoc::InlineDataHelper.generate_inline_values(self.labelings.for_rdf_class(relation_name).
                                                        select{|assoc| assoc.target.language.to_s == language.to_s}.map { |l| l.target.value })
    end

    protected

    # Handle save or destruction of inline labelings for use with widgets etc.
    def process_inline_labelings
      # Inline assigned SKOS::Labels
      # @inline_labelings # => {'skos:altLabel' => {'lang' => 'label1, label2, ...'}}
      (@inline_labelings ||= {}).each do |rdf_name, lang_values|
        self.labelings.for_rdf_class(rdf_name).each do |lbl|
          self.labelings.delete(lbl.destroy)
        end

        lang_values.each do |lang, inline_values|
          lang = nil if lang.to_s == 'none'
          Iqvoc::InlineDataHelper.parse_inline_values(inline_values).each do |value|
            value.squish!
            unless value.blank?
              tokens = {:ObjectLangstringLanguage => lang, :ObjectLangstringString => value, :Predicate => rdf_name}
              self.labelings.build_from_parsed_tokens(tokens, :subject_instance => self)
            end
          end
        end
      end

    end
  end
end

