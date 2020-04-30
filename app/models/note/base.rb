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

class Note::Base < ApplicationRecord
  self.table_name = 'notes'

  class_attribute :rdf_namespace, :rdf_predicate
  self.rdf_namespace = nil
  self.rdf_predicate = nil

  # ********** Validations

  # FIXME: throws validation errors
  # validates :position, uniqueness: { scope: [:owner_id, :owner_type] }
  validates :position, numericality: { greater_than: 0 }

  # FIXME: None?? What about language and value?

  # ********** Associations

  belongs_to :owner,
             polymorphic: true

  belongs_to :concept,
             class_name: Iqvoc::Concept.base_class_name,
             foreign_key: 'owner_id',
             optional: true

  belongs_to :collection,
             class_name: Iqvoc::Collection.base_class_name,
             foreign_key: 'owner_id',
             optional: true

  has_many :annotations,
           class_name: 'Note::Annotated::Base',
           foreign_key: :note_id,
           dependent: :destroy,
           inverse_of: :note

  accepts_nested_attributes_for :annotations

  # ********** Scopes

  default_scope { order(position: :asc) }

  before_validation(on: :create) do
    if position.blank?
      self.position = (self&.owner&.send(Iqvoc.change_note_class_name.to_relation_name)&.maximum(:position) || 0).succ
    end
  end

  def self.by_language(lang_code)
    lang_code = Array.wrap(lang_code).flatten.compact

    if lang_code.none? || lang_code.include?(nil)
      where(arel_table[:language].eq(nil).or(arel_table[:language].in(lang_code)))
    else
      where(language: lang_code)
    end
  end

  def self.by_query_value(query)
    where(["LOWER(#{table_name}.value) LIKE ?", query.mb_chars.downcase.to_s])
  end

  def self.by_owner_type(klass)
    where(owner_type: klass.is_a?(ActiveRecord::Base) ? klass.name : klass)
  end

  def self.for_concepts
    where(owner_type: 'Concept::Base')
  end

  def self.for_labels
    where(owner_type: 'Label::Base')
  end

  def self.by_owner(owner)
    if owner.is_a?(Label::Base)
      for_labels.where(owner_id: owner.id)
    elsif owner.is_a?(Concept::Base)
      for_concepts.where(owner_id: owner.id)
    else
      raise "Note::Base.by_owner: Unknown owner (#{owner.inspect})"
    end
  end

  # ********** Methods

  def <=>(other)
    self.to_s.downcase <=> other.to_s.downcase
  end

  # TODO: This should move to umt because the "list" is more or less proprietary
  def from_annotation_list!(str)
    str.gsub(/\[|\]/, '').split('; ').map { |a| a.split(' ') }.each do |annotation|
      namespace, predicate = annotation.first.split(':', 2)
      annotations << Note::Annotated::Base.new(value: annotation.second,
          namespace: namespace, predicate: predicate)
    end
    self
  end

  def to_s
    "#{self.value}"
  end

  def self.view_section(obj)
    'notes'
  end

  def self.view_section_sort_key(obj)
    100
  end

  def self.partial_name(obj)
    'partials/note/base'
  end

  def self.edit_partial_name(obj)
    'partials/note/edit_base'
  end

  def self.single_query(params = {})
    query_str = build_query_string(params)

    scope = by_query_value(query_str).
            by_language(params[:languages].to_a)

    case params[:for]
    when 'concept'
      scope = scope.where('concepts.type' => Iqvoc::Concept.base_class_name)
                   .includes(:concept)
                   .references(:concepts)
      owner = :concept
    when 'collection'
      scope = scope.where('concepts.type' => Iqvoc::Collection.base_class_name)
                   .includes(:concept)
                   .references(:concepts)
      owner = :collection
    else
      # no additional conditions
      scope
    end

    if params[:collection_origin].present?
      collection = Collection::Base.where(origin: params[:collection_origin]).last
      if collection
        if owner
          scope = scope.includes(owner => :collection_members)
        else
          scope = scope.includes(:concept => :collection_members)
                       .includes(:collection => :collection_members)
        end
        scope = scope.where("#{Collection::Member::Base.table_name}.collection_id" => collection.id)
        scope = scope.references(:collection_members)
      else
        raise "Collection with Origin #{params[:collection_origin]} not found!"
      end
    end

    scope = yield(scope) if block_given?
    scope.map { |result| SearchResult.new(result) }
  end

  def self.search_result_partial_name
    'partials/note/search_result'
  end

  def build_search_result_rdf(document, result)
    result.Sdc::link(IqRdf.build_uri(owner.origin))
    build_rdf(document, result)
  end
end
