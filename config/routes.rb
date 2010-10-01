Iqvoc::Application.routes.draw do
  # FIXME 
  # This should be taken from I18n if possible
  available_locales = /de|en/

  # Language parameter is optional
  # RDF/TTL URIs don't need to be localized in any way.
  scope '(:lang)' do
    resources :concepts, :only => [:index]
    resources :labels,   :only => [:index]
  end
  
  # Language paramater is mandatory.
  # FIXME limit lang to locales
  scope ':lang' do
    resource  :user_session
    resources :virtuoso_syncs, :only => [:new, :create]
    
    # The index action is only needed for language-independent
    # JSON URIs, so they are defined in the namespace above this one.

      resources :concepts, :except => :index do
        resources :labelings, :controller => 'concepts/labelings'
        resources :relations, :controller => 'concepts/relations'
      end

      resources :labels, :except => :index do
        resources :relations, :controller => 'labels/relations'
      end


    resources :labelings
    resources :users
    resources :notes
    resources :label_relations
    
    %w(concepts labels).each do |type|
      match "#{type}/versions/:origin/branch"      => "#{type}/versions#branch",    :as => "#{type.singularize}_versions_branch"
      match "#{type}/versions/:origin/merge"       => "#{type}/versions#merge",     :as => "#{type.singularize}_versions_merge"
      match "#{type}/versions/:origin/lock"        => "#{type}/versions#lock",      :as => "#{type.singularize}_versions_lock"
      match "#{type}/versions/:origin/unlock"      => "#{type}/versions#unlock",    :as => "#{type.singularize}_versions_unlock"
      match "#{type}/versions/:origin/to_review"   => "#{type}/versions#to_review", :as => "#{type.singularize}_versions_to_review"
      match "#{type}/versions/:origin/consistency_check" => "#{type}/versions#consistency_check", :as => "#{type.singularize}_versions_consistency_check"
    end

    match 'alphabetical_concepts/:letter'   => 'alphabetical_concepts#index', :as => 'alphabetical_concepts'
    match 'hierarchical_concepts(.:format)' => 'hierarchical_concepts#index', :as => 'hierarchical_concepts'
    match 'hierarchical_broader_concepts(.:format)' => 'hierarchical_broader_concepts#index', :as  => 'hierarchical_broader_concepts'

    match 'search'    => 'search_results#index', :as => 'search'
    match 'about'     => 'pages#about',          :as => 'about'
    match 'dashboard' => 'dashboard#index',      :as => 'dashboard'
  end
  
  match 'suggest/concepts.:format' => 'concepts#index', :as => 'concept_suggestion'
  match 'suggest/labels.:format'   => 'labels#index',   :as => 'label_suggestion'

  resources :sns_services do
    collection do
      get :get_synonyms
    end
  end

  match '/:lang' => 'hierarchical_concepts#index', :lang => available_locales, :as => 'localized_root'

  root :to => redirect("/de")
end
