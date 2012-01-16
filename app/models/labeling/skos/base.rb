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

class Labeling::SKOS::Base < Labeling::Base

  self.rdf_namespace = "skos"

  # ********** Associations

  belongs_to :target, :class_name => "Label::Base", :dependent => :destroy # the destroy is new

  # ********** Scopes

  scope :by_label_with_language, lambda { |label, language|
    includes(:target).merge(self.label_class.where(:value => label, :language => language))
  }

  # ********** Methods

  def self.label_class
    Iqvoc::Label.base_class
  end

  def self.partial_name(obj)
    "partials/labeling/skos/base"
  end

  def self.edit_partial_name(obj)
    "partials/labeling/skos/edit_base"
  end

  def self.single_query(params = {})
    query_str = build_query_string(params)

    scope = includes(:target).order("LOWER(#{Label::Base.table_name}.value)")

    if params[:query].present?
      scope = scope.merge(Label::Base.by_query_value(query_str).by_language(params[:languages].to_a).published)
    else
      scope = scope.merge(Label::Base.by_language(params[:languages].to_a).published)
    end

    if params[:collection_origin].present?
      collection = Collection::Unordered.where(:origin => params[:collection_origin]).last
      if collection
        scope = scope.includes(:owner => :collection_members)
        scope = scope.where("#{Collection::Member::Base.table_name}.collection_id" => collection)
      else
        raise "Collection with Origin #{params[:collection_origin]} not found!"
      end
    end
    scope = scope.includes(:owner)
    
    scope = case params[:for]
    when "concept"
      scope.where("concepts.type" => Iqvoc::Concept.base_class_name).merge(Concept::Base.published)
    when "collection"
      scope.where("concepts.type" => Iqvoc::Collection.base_class_name)
    else
      # no additional conditions
      scope
    end
    
    scope
  end

  def self.search_result_partial_name
    'partials/labeling/skos/search_result'
  end

  def self.build_from_rdf(subject, predicate, object)
    raise "Labeling::SKOS::Base#build_from_rdf: Subject (#{subject}) must be a Concept." unless subject.is_a?(Concept::Base)
    raise "Labeling::SKOS::Base#build_from_rdf: Object (#{object}) must be a string literal" unless object =~ /^"(.+)"(@(.+))$/
    
    lang = $3
    value = JSON.parse(%Q{["#{$1}"]})[0].gsub("\\n", "\n") # Trick to decode \uHHHHH chars

    subject.send(self.name.to_relation_name) << self.new(:target => self.label_class.new(:value => value, :language => lang))
  end

  def build_rdf(document, subject)
    subject.send(self.rdf_namespace.camelcase).send(self.rdf_predicate, target.to_s, :lang => target.language)
  end

  def build_search_result_rdf(document, result)
    result.Sdc::link(IqRdf.build_uri(owner.origin))
    build_rdf(document, result)
  end

end
