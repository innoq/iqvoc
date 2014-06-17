# encoding: UTF-8

# Copyright 2011-2014 innoQ Deutschland GmbH
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

class Concepts::DraftController < ConceptsController
  def index
    authorize! :read, Iqvoc::Concept.base_class

    scope = Iqvoc::Concept.base_class

    # only select unexpired concepts
    scope = scope.not_expired

    @concepts = scope.tops.includes(:narrower_relations).references(:concepts)

    # When in single query mode, AR handles ALL includes to be loaded by that
    # one query. We don't want that! So let's do it manually :-)
    ActiveRecord::Associations::Preloader.new.preload(@concepts,
        Iqvoc::Concept.base_class.default_includes + [:pref_labels])

    @concepts.to_a.sort! do |a, b|
      a.pref_label.to_s <=> b.pref_label.to_s
    end
  end
end
