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

  self.rdf_namespace = 'skos'

  def self.build_from_rdf(rdf_subject, rdf_predicate, rdf_object)
    rdf_subject    = Concept::Base.from_origin_or_instance(rdf_subject)
    rdf_object     = Concept::Base.from_origin_or_instance(rdf_object)
    relation_class = Iqvoc::RDFAPI::PREDICATE_DICTIONARY[rdf_predicate] || self

    relation_instance = rdf_subject.send(relation_class.relation_name).select{|rel| rel.target == object }
    unless relation_instance
      relation_instance = relation_class.new(:target => rdf_object)
      rdf_subject.send(relation_class.relation_name) << relation_instance
    end

    if relation_class.bidirectional?
      reverse_class      = relation_class.reverse_relation_class
      reverse_collection = rdf_object.send(reverse_class.name.to_relation_name)
      if reverse_collection.select{|rel| rel.target == rdf_subject}.empty?
        reverse_instance = reverse_class.new(:target => rdf_subject)
        reverse_collection << reverse_instance
      end
    end
  end

  def build_rdf(document, subject)
    subject.send(self.rdf_namespace.camelcase).send(self.rdf_predicate, IqRdf.build_uri(target.origin))
  end

end
