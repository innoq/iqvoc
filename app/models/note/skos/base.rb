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

class Note::SKOS::Base < Note::Base

  self.rdf_namespace = 'skos'

  def self.build_from_rdf(rdf_subject, rdf_predicate, rdf_object)
    rdf_subject = Concept::Base.from_origin_or_instance(rdf_subject)
    unless rdf_subject.class.reflections.include?(self.name.to_relation_name)
      raise "#{self.name}#build_from_rdf: Subject (#{rdf_subject}) must be able to receive this kind of note (#{self.name} => #{self.name.to_relation_name})."
    end

    target_class = Iqvoc::RDFAPI::PREDICATE_DICTIONARY[rdf_predicate] || self
    case rdf_object
    when String # Literal
      unless rdf_object =~ /^"(.*)"(@(.+))$/
        raise "#{self.name}#build_from_rdf: Object (#{rdf_object}) must be a string literal"
      end
      lang = $3
      value = JSON.parse(%Q{["#{$1}"]})[0].gsub("\\n", "\n") # Trick to decode \uHHHHH chars
      target_class.new(:value => value, :language => lang).tap do |new_instance|
        rdf_subject.send(target_class.name.to_relation_name) << new_instance
      end
    when Array # Blank node
      note = target_class.create!(:owner => rdf_subject)
      rdf_object.each do |annotation|
        ns, pred = *annotation.first.split(":", 2)
        note.annotations.create! do |a|
          a.namespace = ns
          a.predicate = pred
          a.value = annotation.last.match(/^"(.+)"$/)[1]
        end
      end
    end
  end

  def build_rdf(document, subject)
    ns, id = '', ''
    if self.rdf_namespace and self.rdf_predicate
      ns, id = self.rdf_namespace, self.rdf_predicate
    elsif self.class == Note::SKOS::Base # This could be done by setting self.rdf_predicate to 'note'. But all subclasses would inherit this value.
      ns, id = 'Skos', 'note'
    else
      raise "#{self.class.name}#build_rdf: Class #{self.class.name} needs to define self.rdf_namespace and self.rdf_predicate."
    end

    if (IqRdf::Namespace.find_namespace_class(ns))
      subject.send(ns).send(id, value, :lang => language)
    else
      raise "#{self.class.name}#build_rdf: couldn't find Namespace '#{ns}'."
    end
  end

end
