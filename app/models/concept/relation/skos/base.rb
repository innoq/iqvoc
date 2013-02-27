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

class Concept::Relation::SKOS::Base < Concept::Relation::Base

  def self.build_from_rdf(rdf_subject, rdf_predicate, rdf_object)
    rdf_subject    = Concept::Base.from_origin_or_instance(rdf_subject)
    rdf_object     = Concept::Base.from_origin_or_instance(rdf_object)
    relation_class = Iqvoc::RDFAPI::PREDICATE_DICTIONARY[rdf_predicate] || self

    relation_instance = rdf_subject.relations.find_by_target_and_class(rdf_object, relation_class)
    unless relation_instance
      relation_instance = relation_class.new(:target => rdf_object, :owner => rdf_subject)
      # TODO: make sure this relation instance is eventually saved!
    end

    if relation_class.bidirectional?
      reverse_class      = relation_class.reverse_relation_class
      reverse_instance   = rdf_object.relations.find_by_target_and_class(rdf_subject, reverse_class)
      reverse_instance ||= reverse_class.new(:target => rdf_subject, :owner => rdf_object)
      # TODO: make sure this relation instance is eventually saved!
    end
  end

  def build_rdf(document, subject)
    subject.send(self.rdf_namespace.camelcase).send(self.rdf_predicate, IqRdf.build_uri(target.origin))
  end

end
