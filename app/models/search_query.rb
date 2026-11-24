# encoding: UTF-8

# Copyright 2011-2016 innoQ Deutschland GmbH
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

# Value object for the parameters of a search request: applies defaults,
# normalizes values and validates them. Its attributes use long names
# (`query`, `type`, ...) internally. In URLs and in everything outside of
# search handling the short names of the API documentation (`q`, `t`, ...) are
# used; the long names are only still accepted in incoming URLs for backwards
# compatibility.
class SearchQuery
  include ActiveModel::Model
  include ActiveModel::Attributes

  ALLOWED_QUERY_TYPES = %w[exact contains begins_with ends_with].freeze
  ALLOWED_TYPES = Iqvoc.searchable_class_names.values.freeze

  # Language selection: "l[]=de&l[]=en" as well as "l=de,en" are accepted.
  class LanguagesType < ActiveModel::Type::Value
    def cast(value)
      case value
      when nil then nil
      when Array then value
      else value.to_s.split(',')
      end
    end
  end

  # Short URL parameter => attribute. Other attributes use their own name.
  URL_PARAM_NAMES = {
    q: :query,
    t: :type,
    l: :languages,
    qt: :query_type,
    c: :collection_origin,
    ds: :datasets
  }.freeze
  DIRECT_URL_PARAM_NAMES = %i[for include_expired note change_note_type change_note_date_from change_note_date_to].freeze

  attribute :query, :string
  attribute :query_type, :string, default: 'contains'
  attribute :type, :string, default: -> { SearchQuery.default_type }
  attribute :languages, LanguagesType.new, default: -> { SearchQuery.default_languages }
  attribute :collection_origin, :string
  attribute :datasets
  attribute :for, :string, default: 'all'
  attribute :include_expired, :boolean, default: false
  attribute :note, :string
  attribute :change_note_type, :string
  attribute :change_note_date_from, :string
  attribute :change_note_date_to, :string

  validates :query_type, inclusion: { in: ALLOWED_QUERY_TYPES }, allow_blank: true
  # a search type is only needed once a search was submitted
  validates :type, inclusion: { in: ->(_query) { Iqvoc.searchable_class_names.values } }, if: :submitted?

  def self.default_type
    Iqvoc.searchable_class_names.values.first
  end

  # Language codes as used in the UI ('none' stands for "no language")
  def self.default_languages
    Iqvoc.all_languages.map { |lang| lang || 'none' }
  end

  def submitted?
    !query.nil?
  end

  # Language codes for querying: "none" selects the "nil language" only.
  def language_codes
    languages.include?('none') ? [nil] : languages
  end

  def search_class_name
    Iqvoc.searchable_class_names.detect { |_name, type| type == self.type }.try(:first)
  end

  def search_class
    search_class_name.try(:constantize)
  end

  # Builds a query from URL parameters. Missing values are left out so the
  # defaults apply. Short names are the documented ones and win over the long
  # names (legacy, still accepted).
  def self.from_url_params(params)
    raw = params.to_unsafe_h.symbolize_keys
    new(raw.slice(*URL_PARAM_NAMES.values)
           .merge(raw.slice(*URL_PARAM_NAMES.keys).transform_keys(URL_PARAM_NAMES))
           .merge(raw.slice(*DIRECT_URL_PARAM_NAMES))
           .compact)
  end

  # Normalized values under their URL parameter names (inverse of
  # `from_url_params`), e.g. for views reading `params`.
  def to_url_params
    URL_PARAM_NAMES.transform_values { |name| public_send(name) }
                   .merge(DIRECT_URL_PARAM_NAMES.index_with { |name| public_send(name) })
  end

  # Hash handed to the searchable classes' `single_query` (long names, the
  # interface of the searchable classes).
  def to_params
    {
      query: self.query,
      query_type: self.query_type,
      type: self.type,
      languages: self.language_codes,
      collection_origin: self.collection_origin,
      datasets: self.datasets,
      for: self.for,
      include_expired: self.include_expired,
      note: self.note,
      change_note_type: self.change_note_type,
      change_note_date_from: self.change_note_date_from,
      change_note_date_to: self.change_note_date_to
    }
  end
end
