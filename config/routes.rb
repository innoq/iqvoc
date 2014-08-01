# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Rails.application.routes.draw do
  apipie

  scope ':lang', constraints: Iqvoc.routing_constraint do
    Iqvoc.localized_routes.each do |hook|
      hook.call(self)
      ActiveSupport::Deprecation.warn <<-EOF
        Adding routes via `Iqvoc.localized_routes` is deprecated and will
        be removed in iQvoc 4.5.
      EOF
    end

    resource  :user_session, only: [:new, :create, :destroy]
    resources :users, except: [:show]
    resources :concepts
    resources :collections
    resources :imports, only: [:index, :show, :create]
    resources :exports, only: [:index, :show, :create] do
      get 'download'
    end

    get 'scheme' => 'concepts/scheme#show', as: 'scheme'
    get 'scheme/edit' => 'concepts/scheme#edit', as: 'edit_scheme'
    patch 'scheme' => 'concepts/scheme#update'

    get 'hierarchy' => 'hierarchy#index'
    get 'hierarchy/:root' => 'hierarchy#show'

    get 'triplestore_sync' => 'triplestore_sync#index'
    post 'triplestore_sync' => 'triplestore_sync#sync'

    post 'concepts/:origin/branch'      => 'concepts/versions#branch',    as: 'concept_versions_branch'
    post 'concepts/:origin/merge'       => 'concepts/versions#merge',     as: 'concept_versions_merge'
    post 'concepts/:origin/lock'        => 'concepts/versions#lock',      as: 'concept_versions_lock'
    post 'concepts/:origin/unlock'      => 'concepts/versions#unlock',    as: 'concept_versions_unlock'
    post 'concepts/:origin/to_review'   => 'concepts/versions#to_review', as: 'concept_versions_to_review'
    get 'concepts/:origin/consistency_check' => 'concepts/versions#consistency_check', as: 'concept_versions_consistency_check'

    patch 'concepts/:origin/move'        => 'concepts#move',               as: 'move_concept'

    post 'collections/:origin/branch'      => 'collections/versions#branch',    as: 'collection_versions_branch'
    post 'collections/:origin/merge'       => 'collections/versions#merge',     as: 'collection_versions_merge'
    post 'collections/:origin/lock'        => 'collections/versions#lock',      as: 'collection_versions_lock'
    post 'collections/:origin/unlock'      => 'collections/versions#unlock',    as: 'collection_versions_unlock'
    post 'collections/:origin/to_review'   => 'collections/versions#to_review', as: 'collection_versions_to_review'
    get 'collections/:origin/consistency_check' => 'collections/versions#consistency_check', as: 'collection_versions_consistency_check'

    get 'alphabetical_concepts(/:prefix)' => 'concepts/alphabetical#index', as: 'alphabetical_concepts'
    get 'untranslated_concepts/:prefix'   => 'concepts/untranslated#index', as: 'untranslated_concepts'
    get 'hierarchical_concepts' => 'concepts/hierarchical#index', as: 'hierarchical_concepts'
    get 'expired_concepts' => 'concepts/expired#index', as: 'expired_concepts'

    get 'dashboard' => 'dashboard#index', as: 'dashboard'
    match 'dashboard/reset' => 'dashboard#reset', as: 'reset', via: [:get, :post]

    get 'config' => 'instance_configuration#index', as: 'instance_configuration'
    patch 'config' => 'instance_configuration#update'

    get 'search' => 'search_results#index', as: 'search'

    get 'help' => 'pages#help', as: 'help'

    get '/' => 'frontpage#index'
    # root to: 'frontpage#index', format: nil
  end

  patch ':origin/add_match'   => 'reverse_matches#add_match',          as: 'add_match'
  patch ':origin/remove_match'=> 'reverse_matches#remove_match',       as: 'remove_match'
  get 'remote_labels' => 'remote_labels#show', as: 'remote_label'
  get 'schema' => redirect('/'), as: 'schema'
  get 'dataset' => 'rdf#dataset', as: 'rdf_dataset'
  get 'scheme' => 'concepts/scheme#show', as: 'rdf_scheme'
  get 'search' => 'search_results#index', as: 'rdf_search'
  get 'hierarchy' => 'hierarchy#index'
  get 'hierarchy/:root' => 'hierarchy#show'

  get ':id' => 'rdf#show', as: 'rdf'

  get 'collections', as: 'rdf_collections', to: 'collections#index'

  root to: 'frontpage#index', format: nil
end
