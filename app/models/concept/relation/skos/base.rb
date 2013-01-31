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

  def self.build_from_rdf(subject, predicate, object)
    raise "Labeling::SKOS::Base#build_from_rdf: Subject (#{subject}) must be a Concept." unless subject.is_a?(Concept::Base)
    raise "Labeling::SKOS::Base#build_from_rdf: Object (#{object}) must be a Concept." unless object.is_a?(Concept::Base)

    if subject.relations.for_class(self).select{|rel| rel.target_id == object.id || rel.target == object}.empty?
      subject.relations.for_class(self) << self.new(:target => object)
    end

    if self.reverse_relation_class && object.relations.for_class(self.reverse_relation_class).select{|rel| rel.target_id == subject.id || rel.target == subject}.empty?
      object.relations.for_class(self.reverse_relation_class) << self.reverse_relation_class.new(:target => subject)
    end
  end

  def build_rdf(document, subject)
    subject.send(self.rdf_namespace.camelcase).send(self.rdf_predicate, IqRdf.build_uri(target.origin))
  end

end
