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

module LabelsHelper
  
  def render_label_association(hash, label, association_class, further_options = {})
    return unless association_class.partial_name(label)
    ((hash[association_class.view_section(label)] ||= {})[association_class.view_section_sort_key(label)] ||= "") <<
      render(association_class.partial_name(label), further_options.merge(:label => label, :klass => association_class))
  end

  def label_view_data(label)
    res = {'main' => {}}

    res['main'][10] = render 'labels/value_and_language', :label => label

    res['main'][1000] = render 'labels/details', :label => label

    Iqvoc::Concept.labeling_classes.keys.each do |labeling_class|
      render_label_association(res, label, labeling_class)
    end

    Iqvoc::XLLabel.relation_classes.each do |relation_class|
      render_label_association(res, label, relation_class)
    end

    Iqvoc::XLLabel.note_classes.each do |note_class|
      render_label_association(res, label, note_class)
    end

    Iqvoc::XLLabel.additional_association_classes.keys.each do |assoc_class|
      render_label_association(res, label, assoc_class)
    end

    res
  end

end
