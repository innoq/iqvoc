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

module ConceptsHelper
  # if `broader` is supplied, the tree's direction is reversed (descendants represent broader relations)
  def treeview(concepts, broader = false, dragabble = false)
    render "concepts/hierarchical/treeview", concepts: concepts, broader: broader, dragabble: dragabble
  end

  # turns a hash of concept/relations pairs of arbitrary nesting depth into the
  # corresponding HTML list
  def nested_list(hash, options={})
    ordered = options[:ordered] || false
    options.delete(:ordered)

    content_tag(ordered ? 'ol' : 'ul', options) do
      hash.map do |concept, rels|
        rels.empty? ? content_tag('li', concept) : content_tag('li') do
          h(concept) + nested_list(rels, ordered: ordered) # NB: recursive
        end
      end.join("\n").html_safe
    end
  end

  def letter_selector(letters = ('A'..'Z').to_a, &block)
    content_tag :ul, class: 'letter-selector list-unstyled' do
      letters.map do |letter|
        content_tag :li, link_to(letter, yield(letter)),
          class: ('active' if params[:prefix] == letter.to_s.downcase)
      end.join('').html_safe
    end
  end

  # Renders associated objects of a given concept to a hash structure.
  # This hash is taken by view/layouts/_sections to be rendered.
  def concept_view_data(concept)
    res = {}

    render_concept_association(res, concept, Collection::Member::Base)

    Iqvoc::Concept.labeling_classes.each do |labeling_class, languages|
      render_concept_association(res, concept, labeling_class, available_languages: languages || Iqvoc.available_languages)
    end

    Iqvoc::Concept.relation_classes.each do |relation_class|
      render_concept_association(res, concept, relation_class)
    end

    render_match_association(res, concept, Iqvoc::Concept.match_classes)

    Iqvoc::Concept.note_classes.each do |note_class|
      render_concept_association(res, concept, note_class)
    end

    Iqvoc::Concept.notation_classes.each do |notation_class|
      render_concept_association(res, concept, notation_class)
    end

    Iqvoc::Concept.additional_association_classes.keys.each do |assoc_class|
      render_concept_association(res, concept, assoc_class)
    end

    res
  end

  def concept_header(concept)
    desc = concept.class.model_name.human

    if concept.expired_at
      desc += " #{t('txt.views.concepts.expired_at', date: l(concept.expired_at, format: :long))} "
    end

    title = concept.pref_label || concept.origin

    page_header title: title.to_s, desc: desc.html_safe
  end

  private

  #FIXME: Problem: spezielle methoden, weil es ganz aussen rum muss
  # Renders a partial taken from the .partial_name method of the objects
  # associated to the concept.
  def render_concept_association(hash, concept, association_class, further_options = {})
    html = if association_class.respond_to?(:hidden?) && association_class.hidden?(concept)
      ''
    else
      render(association_class.partial_name(concept), further_options.merge(concept: concept, klass: association_class))
    end
    # Convert the already safely buffered string back to a regular one
    # in order to be able to modify it with squish
    if String.new(html).squish.present?
      ((hash[association_class.view_section(concept)] ||= {})[association_class.view_section_sort_key(concept)] ||= '') << html.html_safe
    end
  end

  def render_match_association(hash, concept, association_classes, further_options = {})
    matches_html = ''
    association_classes.each do |association_class|
      matches_html += if association_class.respond_to?(:hidden?) && association_class.hidden?(concept)
        ''
      else
        render(association_class.partial_name(concept), further_options.merge(concept: concept, klass: association_class))
      end
    end
    html = render partial: '/partials/match/panel', locals: { body: matches_html }
    if String.new(html).squish.present?
      ((hash[association_classes.first.view_section(concept)] ||= {})[association_classes.first.view_section_sort_key(concept)] ||= '') << html.html_safe
    end
  end
end
