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
  scope ':lang', :constraints => lambda { |params, req|
    langs = Iqvoc::Concept.pref_labeling_languages.join('|').presence || 'en'
    return params[:lang].to_s =~ /^#{langs}$/
  } do

    Iqvoc.localized_routes.each { |hook| hook.call(self) }

    resource  :user_session, :only => [:new, :create, :destroy]
    resources :users, :except => [:show]
    resources :concepts
    resources :collections

    get 'scheme' => 'concepts/scheme#show', :as => 'scheme'
    get 'scheme/edit' => 'concepts/scheme#edit', :as => 'edit_scheme'
    patch 'scheme' => 'concepts/scheme#update'

    get 'hierarchy' => 'hierarchy#index'
    get 'hierarchy/:root' => 'hierarchy#show'

    get 'triplestore_sync' => 'triplestore_sync#index'
    post 'triplestore_sync' => 'triplestore_sync#sync'

    post 'concepts/:origin/branch'      => 'concepts/versions#branch',    :as => 'concept_versions_branch'
    post 'concepts/:origin/merge'       => 'concepts/versions#merge',     :as => 'concept_versions_merge'
    post 'concepts/:origin/lock'        => 'concepts/versions#lock',      :as => 'concept_versions_lock'
    post 'concepts/:origin/unlock'      => 'concepts/versions#unlock',    :as => 'concept_versions_unlock'
    post 'concepts/:origin/to_review'   => 'concepts/versions#to_review', :as => 'concept_versions_to_review'
    get 'concepts/:origin/consistency_check' => 'concepts/versions#consistency_check', :as => 'concept_versions_consistency_check'

    get 'alphabetical_concepts(/:prefix)' => 'concepts/alphabetical#index', :as => 'alphabetical_concepts'
    get 'untranslated_concepts/:prefix'   => 'concepts/untranslated#index', :as => 'untranslated_concepts'
    get 'hierarchical_concepts' => 'concepts/hierarchical#index', :as => 'hierarchical_concepts'
    get 'expired_concepts' => 'concepts/expired#index', :as => 'expired_concepts'

    get 'dashboard' => 'dashboard#index', :as => 'dashboard'

    get 'config' => 'instance_configuration#index', :as => 'instance_configuration'
    patch 'config' => 'instance_configuration#update'

    get 'import' => 'import#index', :as => 'import'
    post 'import' => 'import#import'

    get 'search' => 'search_results#index', :as => 'search'

    get 'help' => 'pages#help', :as => 'help'

    get '/' => 'frontpage#index'
    # root :to => 'frontpage#index', :format => nil
  end

  get 'remote_labels' => 'remote_labels#show', :as => 'remote_labels'
  get 'schema' => redirect('/'), :as => 'schema'
  get 'dataset' => 'rdf#dataset', :as => 'rdf_dataset'
  get 'scheme' => 'concepts/scheme#show', :as => 'rdf_scheme'
  get 'search' => 'search_results#index', :as => 'rdf_search'

  get ':id' => 'rdf#show', :as => 'rdf'

  get 'collections', :as => 'rdf_collections', :to => 'collections#index'

  root :to => 'frontpage#index', :format => nil
end
