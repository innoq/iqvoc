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

class Labeling::SKOS::Base < Labeling::Base
  self.rdf_namespace = 'skos'

  # ********** Associations

  belongs_to :target, class_name: 'Label::Base', dependent: :destroy # the destroy is new

  # ********** Scopes

  def self.by_label_with_language(label, language)
    includes(:target).merge(self.label_class.where(value: label, language: language))
  end

  # ********** Methods

  def self.label_class
    Iqvoc::Label.base_class
  end

  def self.partial_name(obj)
    'partials/labeling/skos/base'
  end

  def self.edit_partial_name(obj)
    'partials/labeling/skos/edit_base'
  end

  def self.single_query(params = {})
    query_str = build_query_string(params)

    scope = includes(:target).order("LENGTH(#{Label::Base.table_name}.value)")
    languages = Array(params[:languages])

    if params[:query].present?
      scope = scope.
        merge(Label::Base.by_query_value(query_str).by_language(languages).published).
        references(:labels)
    else
      scope = scope.merge(Label::Base.by_language(languages).published).
        references(:labels)
    end

    if params[:collection_origin].present?
      collection = Iqvoc::Collection.base_class.where(origin: params[:collection_origin]).last
      if collection
        scope = scope.includes(owner: :collection_members)
        scope = scope.where("#{Collection::Member::Base.table_name}.collection_id" => collection.id)
        scope = scope.references(:collection_members)
      else
        raise "Collection with Origin #{params[:collection_origin]} not found!"
      end
    end
    scope = scope.includes(:owner)

    scope = case params[:for]
    when 'concept'
      scope.where('concepts.type' => Iqvoc::Concept.base_class_name).
        references(:concepts)
    when 'collection'
      scope.where('concepts.type' => Iqvoc::Collection.base_class_name).
        references(:concepts)
    else
      # no additional conditions
      scope
    end

    if params[:change_note_date_from].present? || params[:change_note_date_to].present?
      change_note_relation = Iqvoc.change_note_class_name.to_relation_name
      concepts = Concept::Base.base_class.published
                              .includes(change_note_relation.to_sym => :annotations)
                              .references(change_note_relation)
                              .references('note_annotations')

      # change note type filtering
      concepts = case params[:change_note_type]
                 when 'created'
                   concepts.where('note_annotations.predicate = ?', 'created')
                 when 'modified'
                   concepts.where('note_annotations.predicate = ?', 'modified')
                 else
                   concepts.where('note_annotations.predicate = ? OR note_annotations.predicate = ?', 'created', 'modified')
                 end

      if params[:change_note_date_from].present?
        begin
          DateTime.parse(params[:change_note_date_from])
          date_from = params[:change_note_date_from]
          concepts = concepts.where('note_annotations.value >= ?', date_from)
        rescue ArgumentError
          Rails.logger.error "Invalid date was entered for search"
        end
      end

      if params[:change_note_date_to].present?
        begin
          date_to = DateTime.parse(params[:change_note_date_to]).end_of_day.to_s
          concepts = concepts.where('note_annotations.value <= ?', date_to)
        rescue ArgumentError
          Rails.logger.error "Invalid date was entered for search"
        end
      end

      scope = scope.includes(:owner).merge(concepts)
    end

    scope = yield(scope) if block_given?
    scope.map { |result| SearchResult.new(result) }
  end

  def self.search_result_partial_name
    'partials/labeling/skos/search_result'
  end

  def self.build_from_rdf(rdf_subject, rdf_predicate, rdf_object)
    unless rdf_subject.is_a?(Concept::Base)
      raise "#{self.name}#build_from_rdf: Subject (#{rdf_subject}) must be a Concept."
    end

    unless rdf_object =~ RDFAPI::LITERAL_REGEXP
      raise InvalidStringLiteralError, "#{self.name}#build_from_rdf: Object (#{rdf_object}) must be a string literal"
    end

    lang = $3
    value = begin
      JSON.parse(%Q{["#{$1}"]})[0].gsub('\\n', "\n") # Trick to decode \uHHHHH chars
    rescue JSON::ParserError
      $1
    end

    predicate_class = RDFAPI::PREDICATE_DICTIONARY[rdf_predicate] || self
    predicate_class.new(target: self.label_class.new(value: value, language: lang)).tap do |labeling|
      rdf_subject.send(predicate_class.name.to_relation_name) << labeling
    end
  end

  def build_rdf(document, subject)
    subject.send(self.rdf_namespace.camelcase).send(self.rdf_predicate, target.value.to_s, lang: target.language)
  end

  def build_search_result_rdf(document, result)
    result.Sdc::link(IqRdf.build_uri(owner.origin))
    build_rdf(document, result)
  end
end
