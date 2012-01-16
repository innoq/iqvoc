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

Rails.application.routes.draw do

  match 'schema(.:format)' => 'pages#schema', :as => 'schema'

  scope '(:lang)', :lang => /#{Iqvoc::Concept.pref_labeling_languages.join("|").presence || " "}/ do

    resource  :user_session, :only => [:new, :create, :destroy]
    resources :users, :except => [:show]

    resources :concepts
    resources :collections

    resources :triple_store_syncs, :only => [:new, :create]

    match "concepts/:origin/branch(.:format)"      => "concepts/versions#branch",    :as => "concept_versions_branch"
    match "concepts/:origin/merge(.:format)"       => "concepts/versions#merge",     :as => "concept_versions_merge"
    match "concepts/:origin/lock(.:format)"        => "concepts/versions#lock",      :as => "concept_versions_lock"
    match "concepts/:origin/unlock(.:format)"      => "concepts/versions#unlock",    :as => "concept_versions_unlock"
    match "concepts/:origin/to_review(.:format)"   => "concepts/versions#to_review", :as => "concept_versions_to_review"
    match "concepts/:origin/consistency_check(.:format)" => "concepts/versions#consistency_check", :as => "concept_versions_consistency_check"

    match 'alphabetical_concepts/:letter(.:format)'   => 'concepts/alphabetical#index', :as => 'alphabetical_concepts'
    match 'untranslated_concepts/:letter(.:format)'   => 'concepts/untranslated#index', :as => 'untranslated_concepts'
    match 'hierarchical_concepts(.:format)' => 'concepts/hierarchical#index', :as => 'hierarchical_concepts'

    match 'hierarchical_collections(.:format)' => 'collections/hierarchical#index', :as => 'hierarchical_collections'

    match 'about(.:format)'     => 'pages#about',          :as => 'about'
    match 'dashboard(.:format)' => 'dashboard#index',      :as => 'dashboard'

    get "import" => "import#index", :as => 'import'
    post "import" => "import#import"

    match 'search(.:format)' => 'search_results#index', :as => 'search'

    root :to => 'concepts/hierarchical#index', :format => nil
  end

  match '/:id(.:format)' => 'rdf#show', :as => 'rdf'
end
