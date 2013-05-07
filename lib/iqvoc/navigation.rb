module Iqvoc
  module Navigation
    EXTENSION_INDEX = -3

    def self.items
      Iqvoc.navigation_items
    end

    def self.add(item)
      items.insert(EXTENSION_INDEX, item)
    end

    def self.add_grouped(item)
      setup_extension_group
      items[EXTENSION_INDEX][:items] << item
    end

    private
    # Setup an empty navigation group for extensions
    def self.setup_extension_group
      if !items[EXTENSION_INDEX][:items]
        items.insert(EXTENSION_INDEX, {
          :text  => proc { t("txt.views.navigation.extensions") },
          :items => []
        })
      end
    end
  end
end
