module Iqvoc
  class Navigation
    LEVELS = [:group, :root]

    class InvalidLevel < ArgumentError; end

    def self.setup
      Navigasmic.setup do |config|
        config.semantic_navigation :primary do |n|

          n.item n.t('txt.views.navigation.dashboard'),
            n.dashboard_path,
            :hidden_unless => n.can?(:use, :dashboard)
          n.item n.t('txt.views.navigation.scheme'),
            n.scheme_path,
            :hidden_unless => n.can?(:read, Iqvoc::Concept.root_class.instance)
          n.item n.t('txt.views.navigation.concepts'),
            n.hierarchical_concepts_path,
            :highlights_on => [
              { controller: 'concepts/alphabetical' },
              { controller: 'concepts/expired' },
              { controller: 'concepts/untranslated' },
            ]
          n.item n.t('txt.views.navigation.collections'),
            n.collections_path,
            :highlights_on => [{ :controller => 'collections' }]

          ActiveSupport.run_load_hooks :navigation_extensions_on_root_level, n

          ActiveSupport.on_load :navigation_extended_on_group_level do
            n.group n.t('txt.views.navigation.extensions') do
              ActiveSupport.run_load_hooks :navigation_extensions_on_group_level, n
            end
          end

          n.group n.t('txt.views.navigation.administration'), :hidden_unless => n.can?(:use, :administration) do
            n.item n.t('txt.views.navigation.users'),
              n.users_path,
              :hidden_unless => n.can?(:manage, User),
              :highlights_on => [{ :controller => 'users'}]
            n.item n.t('txt.views.navigation.instance_configuration'),
              n.instance_configuration_path,
              :highlights_on => [{ :controller => 'instance_configuration'} ]
          end

          n.group n.t('txt.views.navigation.help') do
            n.item n.t('txt.views.navigation.about'), 'http://iqvoc.net/'
            n.item n.t('txt.views.navigation.help'), n.help_path
          end
        end

        config.builder bootstrap: Navigasmic::Builder::ListBuilder do |builder|
          # Set the nav and nav-pills css (you can also use 'nav nav-tabs') --
          # or remove them if you're using this inside a navbar.
          builder.wrapper_class = 'nav'

          # Set the classed for items that have nested items, and that are
          # nested items.
          builder.has_nested_class = 'dropdown'
          builder.is_nested_class = 'dropdown-menu'

          # For dropdowns to work you'll need to include the bootstrap dropdown js
          # For groups, we adjust the markup so they'll be clickable and be
          # picked up by the javascript.
          builder.label_generator = proc do |label, options, has_link, has_nested|
            if !has_nested || has_link
              "<span>#{label}</span>"
            else
              link_to("#{label}<b class='caret'></b>".html_safe, '#',
                  class: 'dropdown-toggle', data: { toggle: 'dropdown' })
            end
          end

          # For items, we adjust the links so they're '#', and do the same as
          # for groups. This allows us to use more complex
          # highlighting rules for dropdowns.
          builder.link_generator = proc do |label, link, link_options, has_nested|
            if has_nested
              link = '#'
              label << "<b class='caret'></b>"
              options.merge!(class: 'dropdown-toggle',
                  data: { toggle: 'dropdown' })
            end
            link_to(label, link, link_options)
          end
        end
      end
    end

    def self.add_on_level(level = :group, &block)
      unless LEVELS.include?(level)
        raise InvalidLevel, "Navigation can only be extended on levels #{LEVELS.join(' or ')}"
      end

      ActiveSupport.on_load :"navigation_extensions_on_#{level}_level" do |n|
        yield n
      end
      ActiveSupport.run_load_hooks :"navigation_extended_on_#{level}_level"
    end

  end
end
