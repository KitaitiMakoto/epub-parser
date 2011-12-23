require 'enumerabler'

module EPUB
  module Publication
    class Package
      class Manifest
        attr_accessor :id,
                      :items

        # syntax sugar for #items.<<
        def <<(item)
          @items ||= []
          @items << item
        end

        # syntax sugar
        def navs
          items.selector {|i| i.properties.include? 'nav'}
        end

        def nav
          navs.first
        end

        def [](item_id)
          items.selector {|item| item.id == item_id}.first
        end

        class Item
          attr_accessor :id, :href, :media_type, :fallback, :properties, :media_overlay
        end
      end
    end
  end
end
