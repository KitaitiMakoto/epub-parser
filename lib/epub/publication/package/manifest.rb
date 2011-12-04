module EPUB
  module Publication
    class Package
      class Manifest
        attr_accessor :id,
                      :items

        def <<(item)
          @items ||= []
          @items << item
        end

        class Item
          attr_accessor :id, :href, :media_type, :fallback, :properties, :media_overlay
        end
      end
    end
  end
end
