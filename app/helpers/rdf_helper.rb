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

module RdfHelper

  def render_concept(document, concept)
    document << concept.build_rdf_subject(document, controller) do |c|

      concept.collections.each do |collection|
        c.Schema::memberOf(IqRdf::Coll::build_uri(collection.origin))
      end

      c.Schema::expires(concept.expired_at) if concept.expired_at
      c.Owl::deprecated(true) if concept.expired_at and concept.expired_at <= Date.new

      concept.labelings.each do |labeling|
        labeling.build_rdf(document, c)
      end

      concept.relations.each do |relation|
        relation.build_rdf(document, c)
      end

      concept.notes.each do |note|
        note.build_rdf(document, c)
      end

      concept.matches.each do |match|
        match.build_rdf(document, c)
      end

      Iqvoc::Concept.additional_association_class_names.keys.each do |class_name|
        concept.send(class_name.to_relation_name).each do |additional_object|
          additional_object.build_rdf(document, c)
        end
      end
    end

  end
end
