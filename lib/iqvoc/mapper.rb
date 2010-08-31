module ActionController
  module Routing
    class RouteSet
      class Mapper

        @@lang_req = {:lang => /(bg|cs|da|de|el|en|es|et|eu|fi|fr|hu|ir|it|lt|lv|mt|nl|no|pl|pt|ru|ro|sk|sl|sv)/i}

        def semantic_resources(*args)
          options    = args.last.is_a?(Hash) ? args.pop : {}
          controller = options.delete(:controller)
          args.each do |plural_resource|
            singular_resource = plural_resource.to_s.singularize
            controller_name   = (controller || plural_resource).to_s
            with_options options.merge(:controller => controller_name) do |mymap|
              mymap.connect "#{plural_resource}",
                            :action => 'create', :conditions => {:method => :post}
              mymap.connect "#{singular_resource}/:id",
                            :action => 'update', :conditions => {:method => :put}
              mymap.connect "#{singular_resource}/:id",
                            :action => 'destroy', :conditions => {:method => :delete}

              mymap.named_route "#{plural_resource}", "#{plural_resource}",
                            :action => 'index', :conditions => {:method => :get}
              mymap.named_route "new_#{singular_resource}", "#{singular_resource}/new",
                            :action => 'new', :conditions => {:method => :get}
              mymap.named_route "edit_#{singular_resource}", "#{singular_resource}/:id/edit",
                            :action => 'edit', :conditions => {:method => :get}
              mymap.named_route "#{singular_resource}", "#{singular_resource}/:id.:format",
                            :action=>'show', :conditions => {:method=> :get}

            end
          end
        end

        def language_dependent_semantic_resources(*args)
          options    = args.last.is_a?(Hash) ? args.pop : {}
          controller = options.delete(:controller)
          args.each do |plural_resource|
            singular_resource = plural_resource.to_s.singularize
            controller_name   = (controller || plural_resource).to_s
            with_options options.merge(:controller => controller_name, :requirements => @@lang_req) do |mymap|
              mymap.connect ":lang/#{plural_resource}",
                            :action => 'create', :conditions => {:method => :post}
              mymap.connect ":lang/#{singular_resource}/:id",
                            :action => 'update', :conditions => {:method => :put}
              mymap.connect ":lang/#{singular_resource}/:id",
                            :action => 'destroy', :conditions => {:method => :delete}

              mymap.named_route "language_#{plural_resource}", ":lang/#{plural_resource}",
                                :action => 'index', :conditions => {:method => :get}
              mymap.named_route "language_new_#{singular_resource}", ":lang/#{singular_resource}/new",
                                :action => 'new', :conditions => {:method => :get}
              mymap.named_route "language_edit_#{singular_resource}", ":lang/#{singular_resource}/:id/edit",
                                :action => 'edit', :conditions => {:method => :get}
              mymap.named_route "language_#{singular_resource}", ":lang/#{singular_resource}/:id.:format",
                                :action=>'show', :conditions => {:method=> :get}
            end
          end
        end

      end
    end
  end
end
