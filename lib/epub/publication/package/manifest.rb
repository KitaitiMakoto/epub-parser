require 'enumerabler'

module EPUB
  module Publication
    class Package
      class Manifest
        attr_accessor :package,
                      :id
        attr_reader :items

        # syntax sugar for #items.<<
        def <<(item)
          @items ||= []
          item.manifest = self
          @items << item
        end

        # syntax sugar
        def navs
          items.selector {|i| i.properties.include? 'nav'}
        end

        def nav
          navs.first
        end

        def cover_image
          items.selector {|i| i.properties.include? 'cover-image'}.first
        end

        def [](item_id)
          items.selector {|item| item.id == item_id}.first
        end

        class Item
          attr_accessor :manifest,
                        :id, :href, :media_type, :fallback, :properties, :media_overlay,
                        :iri

          def read
            open(iri) {|file| file.read}
          end
        end
      end
    end
  end
end
