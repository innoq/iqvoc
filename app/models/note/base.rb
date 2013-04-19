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

class Note::Base < ActiveRecord::Base

  self.table_name = 'notes'

  include ActsAsRdfPredicate

  # ********** Validations

  # FIXME: None?? What about language and value?

  # ********** Associations

  belongs_to :owner, :polymorphic => true

  has_many :annotations, :class_name => 'Note::Annotated::Base', :foreign_key => :note_id, :dependent => :destroy

  accepts_nested_attributes_for :annotations

  default_scope includes(:annotations)

  # ********** Scopes

  def self.by_language(lang_code)
    if (lang_code.is_a?(Array) && lang_code.include?(nil))
      where(arel_table[:language].eq(nil).or(arel_table[:language].in(lang_code.compact)))
    else
      where(:language => lang_code)
    end
  end

  def self.by_query_value(query)
     where(["LOWER(#{table_name}.value) LIKE ?", query.to_s.downcase])
  end

  def self.by_owner_type(klass)
    where(:owner_type => klass.is_a?(ActiveRecord::Base) ? klass.name : klass)
  end

  def self.for_concepts
    where(:owner_type => 'Concept::Base')
  end

  def self.for_labels
    where(:owner_type => 'Label::Base')
  end

  def self.by_owner(owner)
    if owner.is_a?(Label::Base)
      for_labels.where(:owner_id => owner.id)
    elsif owner.is_a?(Concept::Base)
      for_concepts.where(:owner_id => owner.id)
    else
      raise "Note::Base.by_owner: Unknown owner (#{owner.inspect})"
    end
  end

  # ********** Methods

  def self.build_from_parsed_tokens(tokens, options = {})
    rdf_subject     = options[:subject_instance] || Iqvoc::RDFAPI.cached(tokens[:SubjectOrigin])
    predicate_class = Iqvoc::RDFAPI::PREDICATE_DICTIONARY[tokens[:Predicate]] || self

    unless Iqvoc::Concept.note_class_names.include? predicate_class.name.to_s
      raise "#{predicate_class.name}#build_from_parsed_tokens: #{predicate_class.name} is not an allowed note type. Allowed: #{Iqvoc::Concept.note_class_names}"
    end

    value = JSON.parse(%Q{["#{tokens[:ObjectLangstringString]}"]})[0].gsub('\n', "\n") # Trick to decode \uHHHHH chars
    predicate_class.new(:value => value, :language => tokens[:ObjectLangstringLanguage]).tap do |new_instance|
      rdf_subject.notes << new_instance
    end
  end

  def <=>(other)
    self.to_s.downcase <=> other.to_s.downcase
  end

  # TODO: This should move to umt because the "list" is more or less proprietary
  def from_annotation_list!(str)
    str.gsub(/\[|\]/, '').split('; ').map { |a| a.split(' ') }.each do |annotation|
      namespace, predicate = annotation.first.split(":", 2)
      annotations << Note::Annotated::Base.new(:value => annotation.second,
          :namespace => namespace, :predicate => predicate)
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

    by_query_value(query_str).by_language(params[:languages].to_a)
  end

  def self.search_result_partial_name
    'partials/note/search_result'
  end

  def build_search_result_rdf(document, result)
    result.Sdc::link(IqRdf.build_uri(owner.origin))
    build_rdf(document, result)
  end

end
