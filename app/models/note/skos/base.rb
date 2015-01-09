# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
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

class Note::SKOS::Base < Note::Base
  self.rdf_namespace = 'skos'

  def self.build_from_rdf(rdf_subject, rdf_predicate, rdf_object)
    # https://github.com/rails/rails/issues/16928
    unless rdf_subject.class.reflections.include?(self.name.to_relation_name.to_s)
      raise "#{self.name}#build_from_rdf: Subject (#{rdf_subject}) must be able to receive this kind of note (#{self.name} => #{self.name.to_relation_name.to_s})."
    end

    target_class = RDFAPI::PREDICATE_DICTIONARY[rdf_predicate] || self
    case rdf_object
    when String # Literal
      unless rdf_object =~ RDFAPI::LITERAL_REGEXP
        raise "#{self.name}#build_from_rdf: Object (#{rdf_object}) must be a string literal"
      end
      lang = $3
      value = JSON.parse(%Q{["#{$1}"]})[0].gsub('\\n', "\n") # Trick to decode \uHHHHH chars
      target_class.new(value: value, language: lang).tap do |new_instance|
        rdf_subject.send(target_class.name.to_relation_name) << new_instance
      end
    when Array # Blank node
      note = target_class.create!(owner: rdf_subject)
      rdf_object.each do |annotation|
        ns, pred = *annotation.first.split(':', 2)
        note.annotations.create! do |a|
          a.namespace = ns
          a.predicate = pred
          a.value = annotation.last.match(/^"(.+)"$/)[1]
        end
      end
    end
  end

  def build_rdf(document, subject)
    if annotations.any?
      subject.send(rdf_namespace).build_predicate(rdf_predicate) do |blank_node|
        blank_node.Rdfs::comment(value, lang: language || nil) if value
        annotations.order(:namespace, :predicate).each do |annotation|
          if IqRdf::Namespace.find_namespace_class(annotation.namespace)
            val = if annotation.value =~ RDFAPI::URI_REGEXP
              # Fall back to plain value literal if URI is not parseable
              URI.parse(annotation.value) rescue annotation.value
            else
              annotation.value
            end
            blank_node.send(annotation.namespace.camelcase).send(annotation.predicate, val, lang: annotation.language || nil)
          else
            raise "#{self.class}#build_rdf: can't find namespace '#{annotation.namespace}' for note annotation '#{annotation.id}'."
          end
        end
      end
    else
      subject.send(rdf_namespace).send(rdf_predicate, value, lang: language)
    end
  end
end
