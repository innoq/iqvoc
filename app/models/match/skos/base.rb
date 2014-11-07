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

class Match::SKOS::Base < Match::Base
  self.rdf_namespace = 'skos'

  def self.build_from_rdf(rdf_subject, rdf_predicate, rdf_object)
    raise "#{self.class}#build_from_rdf: Subject (#{rdf_subject}) must be able to receive this kind of match (#{self.name} => #{self.name.to_relation_name})." unless rdf_subject.class.reflections.include?(self.name.to_relation_name)
    raise "#{self.class}#build_from_rdf: Object (#{rdf_object}) must be a URI" unless rdf_object =~ /^<(.+)>$/ # XXX: this assumes nt-format, right?
    uri = $1

    match_class = Iqvoc::RDFAPI::PREDICATE_DICTIONARY[rdf_predicate] || self
    match_class.new(value: uri).tap do |match|
      rdf_subject.send(self.name.to_relation_name) << match
    end
  end

  def build_rdf(document, subject)
    raise "Match::SKOS::Base#build_rdf: Class #{self.name} needs to define self.rdf_namespace and self.rdf_predicate." unless self.rdf_namespace && self.rdf_predicate

    if (IqRdf::Namespace.find_namespace_class(self.rdf_namespace.camelcase))
      subject.send(self.rdf_namespace.camelcase).send(self.rdf_predicate, URI.parse(value))
    else
      raise "#{self.class}#build_rdf: couldn't find Namespace '#{self.rdf_namespace.camelcase}'."
    end
  end
end
