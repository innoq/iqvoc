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

class Concepts::AlphabeticalController < ConceptsController
  skip_before_filter :require_user

  def index
    authorize! :read, Concept::Base

    @pref_labelings = Iqvoc::Concept.pref_labeling_class.
      concept_published.
      label_begins_with(params[:letter]).
      by_label_language(I18n.locale).
      includes(:target).
      order("LOWER(#{Label::Base.table_name}.value)").
      joins(:owner).
      where(:concepts => { :type => Iqvoc::Concept.base_class_name }).
      page(params[:page])

    # When in single query mode, AR handles ALL includes to be loaded by that
    # one query. We don't want that! So let's do it manually :-)
    ActiveRecord::Associations::Preloader.new(@pref_labelings, :owner => Iqvoc::Concept.base_class.default_includes).run
  end

end
