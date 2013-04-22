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

class Notation::Base < ActiveRecord::Base

  self.table_name = 'notations'

  class_attribute :rdf_namespace, :rdf_predicate
  self.rdf_namespace = 'skos'
  self.rdf_predicate = 'notation'

  def self.build_from_rdf(rdf_subject, rdf_predicate, rdf_object)
    # TODO: Adopt this to RDFAPI
    data = rdf_object.match /"(?<value>.+)"\^\^<(?<data_type>.+)>/
    create! :concept_id => rdf_subject.id,
      :value => data[:value],
      :data_type => data[:data_type]
  end

  def self.view_section(obj)
    "main"
  end

  def self.view_section_sort_key(obj)
    500
  end

  def self.partial_name(obj)
    "partials/notation/base"
  end

  def self.edit_partial_name(obj)
    "partials/notation/edit_base"
  end

  def build_rdf(document, subject)
    raise "Notation::Base#build_rdf: Class #{self.name} needs to define self.rdf_namespace and self.rdf_predicate." unless self.rdf_namespace && self.rdf_predicate

    if IqRdf::Namespace.find_namespace_class(self.rdf_namespace.camelcase)
      subject.send(self.rdf_namespace.camelcase).send(self.rdf_predicate, IqRdf::Literal.new(value, :none, URI.parse(data_type)))
    else
      raise "#{self.class}#build_rdf: couldn't find Namespace '#{self.rdf_namespace.camelcase}'."
    end
  end

end
