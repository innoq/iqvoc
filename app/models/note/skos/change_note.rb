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

class Note::SKOS::ChangeNote < Note::SKOS::Base
  self.rdf_predicate = 'changeNote'

  def self.view_section(obj)
    "editor_notes"
  end

  def self.edit_partial_name(obj)
    'partials/note/skos/edit_change_note'
  end

  def self.search_result_partial_name
    'partials/note/skos/change_note/search_result'
  end

  def self.single_query(params = {})
    query_str = build_query_string(params)

    scope = includes(:annotations)
    scope = merge(Note::Annotated::Base.where(Note::Annotated::Base.arel_table[:value].matches(query_str)))
    scope.map { |result| SearchResult.new(result) }
  end

  def build_rdf(document, subject)
    subject.send(self.rdf_namespace).build_predicate(self.rdf_predicate) do |blank_node|
      blank_node.Rdfs::comment(self.value, lang: self.language || nil) if self.value
      self.annotations.each do |annotation|
        if (IqRdf::Namespace.find_namespace_class(annotation.namespace))
          blank_node.send(annotation.namespace.camelcase).send(annotation.predicate, annotation.value)
        else
          raise "Note::SKOS::ChangeNote#build_rdf: couldn't find Namespace '#{annotation.namespace}'."
        end
      end
    end
  end
end
