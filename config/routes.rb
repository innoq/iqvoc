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

Iqvoc::Application.routes.draw do
  available_locales = /de|en/ # FIXME #{I18n.available_locales.map(&:to_s).join('|')}/

  scope '(:lang)' do
    resources :collections
    match 'search(.:format)' => 'search_results#index', :as => 'search'
  end

  match 'schema(.:format)' => 'pages#schema', :as => 'schema'

  scope ':lang', :lang => available_locales do
    resource  :user_session
    resources :users

    resources :concepts
    resources :labels

    resources :virtuoso_syncs, :only => [:new, :create]

    %w(concepts labels).each do |type|
      match "#{type}/versions/:origin/branch(.:format)"      => "#{type}/versions#branch",    :as => "#{type.singularize}_versions_branch"
      match "#{type}/versions/:origin/merge(.:format)"       => "#{type}/versions#merge",     :as => "#{type.singularize}_versions_merge"
      match "#{type}/versions/:origin/lock(.:format)"        => "#{type}/versions#lock",      :as => "#{type.singularize}_versions_lock"
      match "#{type}/versions/:origin/unlock(.:format)"      => "#{type}/versions#unlock",    :as => "#{type.singularize}_versions_unlock"
      match "#{type}/versions/:origin/to_review(.:format)"   => "#{type}/versions#to_review", :as => "#{type.singularize}_versions_to_review"
      match "#{type}/versions/:origin/consistency_check(.:format)" => "#{type}/versions#consistency_check", :as => "#{type.singularize}_versions_consistency_check"
    end

    match 'alphabetical_concepts/:letter(.:format)'   => 'concepts/alphabetical#index', :as => 'alphabetical_concepts'
    match 'hierarchical_concepts(.:format)' => 'concepts/hierarchical#index', :as => 'hierarchical_concepts'

    match 'hierarchical_collections(.:format)' => 'collections/hierarchical#index', :as => 'hierarchical_collections'

    match 'about(.:format)'     => 'pages#about',          :as => 'about'
    match 'dashboard(.:format)' => 'dashboard#index',      :as => 'dashboard'

    # There must be on named route 'localized_root' in order for an unlocalized root call to work
    # See ApplicationController#unlocalized_root
    root :to => 'concepts/hierarchical#index', :as => 'localized_root'
  end

  match 'suggest/concepts.:format' => 'concepts#index', :as => 'concept_suggestion'
  match 'suggest/labels.:format'   => 'labels#index',   :as => 'label_suggestion'

  root :to => 'application#unlocalized_root'

  match '/:id(.:format)' => 'rdf#show', :as => 'rdf'
end
