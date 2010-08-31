# the big ugly ball of meat has been moved to lib/iqvoc/mapper.rb
require 'lib/iqvoc/mapper'

ActionController::Routing::Routes.draw do |map|
  
  available_locales = /#{I18n.available_locales.join('|')}/

  map.language_dependent_semantic_resources :concepts, :labels
  map.semantic_resources :concepts, :labels

  map.label_versions_branch ':lang/labels/:origin/versions/branch', 
    :controller => "label_versions", 
    :action => "branch", 
    :conditions => { :method => :post }
  map.label_versions_merge ':lang/labels/:origin/versions/merge', 
    :controller => "label_versions", 
    :action => "merge", 
    :conditions => { :method => :post }
  map.label_versions_lock ':lang/labels/:origin/versions/lock', 
    :controller => "label_versions", 
    :action => "lock", 
    :conditions => { :method => :post }
  map.label_versions_unlock ':lang/labels/:origin/versions/unlock', 
    :controller => "label_versions", 
    :action => "unlock", 
    :conditions => { :method => :post }
  map.label_consistency_check ':lang/labels/:origin/versions/consistency_check', 
    :controller => "label_versions",
    :action => "consistency_check",
    :conditions => { :method => :get }
  map.label_versions_to_review ':lang/labels/:origin/versions/to_review',
    :controller => "label_versions",
    :action => "to_review",
    :conditions => { :method => :post }

  map.concept_versions_branch ':lang/concepts/:origin/versions/branch', 
    :controller => "concept_versions", 
    :action => "branch", 
    :conditions => { :method => :post }
  map.concept_versions_merge ':lang/concepts/:origin/versions/merge', 
    :controller => "concept_versions", 
    :action => "merge", 
    :conditions => { :method => :post }
  map.concept_versions_lock ':lang/concepts/:origin/versions/lock', 
    :controller => "concept_versions", 
    :action => "lock", 
    :conditions => { :method => :post }
  map.concept_versions_unlock ':lang/concepts/:origin/versions/unlock', 
    :controller => "concept_versions", 
    :action => "unlock", 
    :conditions => { :method => :post }
  map.concept_consistency_check ':lang/concepts/:origin/versions/consistency_check',
    :controller => "concept_versions",
    :action => "consistency_check",
    :conditions => { :method => :get }
  map.concept_versions_to_review ':lang/concepts/:origin/versions/to_review',
    :controller => "concept_versions",
    :action => "to_review",
    :conditions => { :method => :post }

  map.alphabetical_concepts ':lang/concepts/alphabetical/:letter',
    :controller   => 'alphabetical_concepts',
    :action       => 'index',
    :conditions   => { :method => :get },
    :requirements => { :lang => available_locales }
  
  map.hierarchical_concepts ':lang/concepts/hierarchical.:format',
    :controller   => 'hierarchical_concepts',
    :action       => 'index',
    :conditions   => { :method => :get },
    :requirements => { :lang => available_locales }

  map.hierarchical_broader_concepts ':lang/concepts/hierarchical_broader.:format',
    :controller   => 'hierarchical_broader_concepts',
    :action       => 'index',
    :conditions   => { :method => :get },
    :requirements => { :lang => available_locales }

  map.search ':lang/search',
    :controller   => 'search_results',
    :action       => 'index',
    :requirements => { :lang => available_locales }

  map.about ':lang/about', :controller => 'pages', :action => 'about'
  map.concept_suggestion "suggest/concepts.:format", :controller => "concepts", :action => "index"
  map.label_suggestion   "suggest/labels.:format", :controller => "labels", :action => "index"
  map.dashboard ":lang/dashboard", :controller => "dashboard"
  map.resources :virtuoso_syncs, :path_prefix => ":lang", :only => [:new, :create]
  
  map.resources :sns_services, :collection => {:get_synonyms => :get}

  map.resource :user_session,       :path_prefix => ':lang'
  map.resources :versioned_labels, :except => :index, :path_prefix => ":lang" do |versioned_label|
    versioned_label.resources :homographs
    versioned_label.resources :qualifiers
    versioned_label.resources :translations
    versioned_label.resources :compound_forms do |compound_form|
      compound_form.resources :compound_form_contents
    end
  end
  map.resources :versioned_concepts, :except => :index, :path_prefix => ":lang" do |versioned_concept|
    versioned_concept.resources :pref_labelings
    versioned_concept.resources :alt_labelings
    versioned_concept.resources :broaders
    versioned_concept.resources :narrowers
    versioned_concept.resources :related

  end
  map.resources :labelings,          :path_prefix => ":lang"
  map.resources :users,              :path_prefix => ":lang"
  map.resources :notes,              :path_prefix => ":lang"
  map.resources :label_relations,    :path_prefix => ":lang"
  map.resources :inflectionals,      :path_prefix => ":lang", :only => [:index]

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => 'gemet_themes'
  map.localized_root ':lang', :controller => 'hierarchical_concepts'
  map.localized_root ':lang', :controller => 'hierarchical_broader_concepts'
  map.root :controller => 'language_switch'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
