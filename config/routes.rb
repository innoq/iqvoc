Iqvoc::Application.routes.draw do
  available_locales = /de|en/
  
  match ':lang/labels/:origin/versions/branch'    => 'label_versions#branch',    :as => 'label_versions_branch'
  match ':lang/labels/:origin/versions/merge'     => 'label_versions#merge',     :as => 'label_versions_merge'
  match ':lang/labels/:origin/versions/lock'      => 'label_versions#lock',      :as => 'label_versions_lock'
  match ':lang/labels/:origin/versions/unlock'    => 'label_versions#unlock',    :as => 'label_versions_unlock'
  match ':lang/labels/:origin/versions/to_review' => 'label_versions#to_review', :as => 'label_versions_to_review'
  match ':lang/labels/:origin/versions/consistency_check' => 'label_versions#consistency_check', :as => 'label_consistency_check'

  match ':lang/concepts/:origin/versions/branch'    => 'concept_versions#branch',    :as => 'concept_versions_branch'
  match ':lang/concepts/:origin/versions/merge'     => 'concept_versions#merge',     :as => 'concept_versions_merge'
  match ':lang/concepts/:origin/versions/lock'      => 'concept_versions#lock',      :as => 'concept_versions_lock'
  match ':lang/concepts/:origin/versions/unlock'    => 'concept_versions#unlock',    :as => 'concept_versions_unlock'
  match ':lang/concepts/:origin/versions/consistency_check' => 'concept_versions#consistency_check', :as => 'concept_consistency_check'
  match ':lang/concepts/:origin/versions/to_review' => 'concept_versions#to_review', :as => 'concept_versions_to_review'

  match ':lang/concepts/alphabetical/:letter'   => 'alphabetical_concepts#index', :as => 'alphabetical_concepts', :via => :get
  match ':lang/concepts/hierarchical(.:format)' => 'hierarchical_concepts#index', :as => 'hierarchical_concepts', :via => :get
  match ':lang/concepts/hierarchical_broader(.:format)' => 'hierarchical_broader_concepts#index', 
    :as  => 'hierarchical_broader_concepts',
    :via => :get
    
  match ':lang/search'    => 'search_results#index', :as => 'search'
  match ':lang/about'     => 'pages#about',          :as => 'about'
  match ':lang/dashboard' => 'dashboard#index',      :as => 'dashboard'
  
  match 'suggest/concepts.:format' => 'concepts#index', :as => 'concept_suggestion'
  match 'suggest/labels.:format'   => 'labels#index',   :as => 'label_suggestion'
  
  scope '(:lang)', :lang => available_locales do
    resources :concepts
    resources :labels
  end
  
  scope ':lang' do
    resource  :user_session
    resources :virtuoso_syncs, :only => [:new, :create]
    
    resources :versioned_concepts, :except => :index do
      resources :pref_labelings
      resources :alt_labelings
      resources :broaders
      resources :narrowers
      resources :related
    end
    
    resources :versioned_labels, :except => :index do
      resources :homographs
      resources :qualifiers
      resources :translations
      resources :compound_forms do
        resources :compound_form_contents
      end
    end
    
    resources :labelings
    resources :users
    resources :notes
    resources :label_relations
    resources :inflectionals, :only => [:index]
  end

  resources :sns_services do
    collection do
      get :get_synonyms
    end
  end
  
  match '/:lang' => 'hierarchical_concepts#index', :lang => available_locales, :as => 'localized_root'

  # map.localized_root ':lang', :controller => 'hierarchical_concepts'
  # map.localized_root ':lang', :controller => 'hierarchical_broader_concepts'
  root :to => redirect("/de")
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
