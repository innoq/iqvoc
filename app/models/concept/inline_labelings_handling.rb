# encoding: UTF-8

# Copyright 2013 innoQ Deutschland GmbH
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
      after_save :persist_labelings
    end

    def inline_labelings=(hash)
      @inline_labelings = {}
      hash.each do |rdf_type, labels_by_lang|
        # if `language` is `nil`, the respective HTML form field returns an array
        # instead of a hash (`<input name=bla[labeling_class][]>`)
        if labels_by_lang.is_a?(Array)
          @inline_labelings[rdf_type] = { nil => labels_by_lang.first }
        else
          @inline_labelings[rdf_type] = labels_by_lang
        end
      end
      @inline_labelings
    end

    def inline_labelings(reload = false)
      if reload
        @inline_labelings = load_inline_labelings
      else
        @inline_labelings ||= load_inline_labelings
      end
    end

    protected

    def persist_labelings
      self.labelings.each &:save
    end

    def load_inline_labelings
      inline_lbls = Hash.new

      self.labelings.each_configured_class do |klass|
        inline_lbls[klass.rdf_internal_name] = {}
        grouped_labelings = self.labelings.for_class(klass).group_by{|l| l.target.language }
        grouped_labelings.each do |language, labelings|
          inline_values = Iqvoc::InlineDataHelper.generate_inline_values(labelings.map {|l| l.target.value })
          inline_lbls[klass.rdf_internal_name][language] = inline_values
        end
      end

      inline_lbls
    end

    # Handle save or destruction of inline labelings for use with widgets etc.
    def process_inline_labelings
      # Inline assigned SKOS::Labels
      # @inline_labelings # => {'skos:altLabel' => {'lang' => '"label1", "label2", ...'}}

      # we iterate using each_configured_class to avoid setting unconfigured label types
      self.labelings.each_configured_class do |labeling_class|
        rdf_name = labeling_class.rdf_internal_name
        if @inline_labelings and @inline_labelings[rdf_name]
          self.labelings.for_class(labeling_class).each do |lbl|
            self.labelings.destroy_later(lbl)
          end

          @inline_labelings[rdf_name].each do |lang, inline_values|
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
end

