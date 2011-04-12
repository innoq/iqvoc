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

module ConceptsHelper
  def select_search_checkbox?(lang)
    (params[:languages] && params[:languages].include?(lang.to_s)) ||
        (!params[:query] && I18n.locale.to_s == lang.to_s)
  end

  def quote_turtle_value(str)
    str.match(/^<.*>$/) ? str : "\"#{str}\""
  end

  def treeview(concepts, root = "source")
    render :partial => "concepts/hierarchical/treeview",
        :locals => { :root => root, :concepts => concepts }
  end

  def render_concept_association(hash, concept, association_class, further_options = {})
    ((hash[association_class.view_section(concept)] ||= {})[association_class.view_section_sort_key(concept)] ||= "") <<
      render(association_class.partial_name(concept), further_options.merge(:concept => concept, :klass => association_class))
  end

  def concept_view_data(concept)
    res = {}

    render_concept_association(res, concept, Collection::Member::Concept)

    Iqvoc::Concept.further_labeling_classes.each do |labeling_class, languages|
      (languages || Iqvoc::available_languages).each do |lang|
        render_concept_association(res, concept, labeling_class, :lang => lang)
      end
    end

    Iqvoc::Concept.relation_classes.each do |relation_class|
      render_concept_association(res, concept, relation_class)
    end

    Iqvoc::Concept.match_classes.each do |match_class|
      render_concept_association(res, concept, match_class)
    end

    Iqvoc::Concept.note_classes.each do |note_class|
      render_concept_association(res, concept, note_class)
    end

    Iqvoc::Concept.additional_association_classes.keys.each do |assoc_class|
      render_concept_association(res, concept, assoc_class)
    end

    res
  end

end
