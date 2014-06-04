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

class Concept::SKOS::Scheme < Concept::Base
  private_class_method :new

  after_update :redeclare_top_concepts

  def self.rdf_class
    'ConceptScheme'
  end

  def self.rdf_predicate
    'topConceptOf'
  end

  def self.rdf_namespace
    'skos'
  end

  def self.build_from_rdf(rdf_subject, rdf_predicate, rdf_object)
    rdf_subject.update_attribute :top_term, true
  end

  def self.instance
    first_or_create!(origin: 'scheme', published_at: Time.now)
  end

  def self.create(attributes = nil, &block)
    raise TypeError, "Singleton" if first
    super
  end

  def self.create!(attributes = nil, &block)
    raise TypeError, "Singleton" if first
    super
  end

  def build_rdf_subject(&block)
    ns = IqRdf::Namespace.find_namespace_class(self.class.rdf_namespace.to_sym)
    raise "Namespace '#{rdf_namespace}' is not defined in IqRdf document." unless ns
    IqRdf.build_uri(origin, ns.build_uri(self.class.rdf_class), &block)
  end

  def top_concepts
    Iqvoc::Concept.base_class.tops
  end

  def inline_top_concept_origins=(origins)
    @inline_top_concept_origins = origins.to_s.
      split(Iqvoc::InlineDataHelper::SPLITTER).map(&:strip)
  end

  def inline_top_concept_origins
    @inline_top_concept_origins || top_concepts.map { |c| c.origin }.uniq
  end

  def inline_top_concepts
    if @inline_top_concept_origins
      Iqvoc::Concept.base_class.editor_selectable.where(origin: @inline_top_concept_origins)
    else
      top_concepts.select { |c| c.editor_selectable? }
    end
  end

  def redeclare_top_concepts
    return if inline_top_concept_origins.nil? # There is nothing to do

    Iqvoc::Concept.base_class.transaction do
      Iqvoc::Concept.base_class.tops.update_all top_term: false
      Iqvoc::Concept.base_class.where(origin: @inline_top_concept_origins).update_all(top_term: true)
    end
  end
end
