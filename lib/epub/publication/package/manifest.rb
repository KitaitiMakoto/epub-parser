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
        def nav
          items.each.select {|i| i.properties.include? 'nav'}.first
        end

        class Item
          attr_accessor :id, :href, :media_type, :fallback, :properties, :media_overlay
        end
      end
    end
  end
end
