require 'enumerabler'
require 'epub/constants'

module EPUB
  module Publication
    class Package
      class Manifest
        attr_accessor :package,
                      :id

        def <<(item)
          @items ||= {}
          item.manifest = self
          @items[item.id] = item
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

        def items
          @items.values
        end

        def [](item_id)
          @items[item_id]
        end

        class Item
          # @!attribute [rw] manifest
          #   @return [Manifest] Returns the value of manifest
          # @!attribute [rw] id
          #   @return [String] Returns the value of id
          # @!attribute [rw] href
          #   @return [String] Returns the value of href
          # @!attribute [rw] media_type
          #   @return [String] Returns the value of media_type
          # @!attribute [rw] properties
          #   @return [Array<String>] Returns the value of properties
          # @!attribute [rw] media_overlay
          #   @return [String] Returns the value of media_overlay
          # @!attribute [rw] fallback
          #   @return [Item] Returns the value of attribute fallback
          # @!attribute [rw] iri
          #   @return [Addressable::URI] Returns the value of attribute iri
          attr_accessor :manifest,
                        :id, :href, :media_type, :fallback, :properties, :media_overlay,
                        :iri

          # @todo Handle circular fallback chain
          def fallback_chain
            return @fallback_chain if @fallback_chain
            @fallback_chain = traverse_fallback_chain([])
          end

          def read
            Zip::Archive.open(manifest.package.book.epub_file) {|zip|
              zip.fopen(iri.to_s).read
            }
          end

          # @todo Handle circular fallback chain
          def use_fallback_chain(options = {})
            supported = EPUB::MediaType::CORE
            if ad = options[:supported]
              supported = supported | (ad.respond_to?(:to_ary) ? ad : [ad])
            end
            if del = options[:unsupported]
              supported = supported - (del.respond_to?(:to_ary) ? del : [del])
            end

            return yield self if supported.include? media_type
            if (bindings = manifest.package.bindings) && (binding_media_type = bindings[media_type])
              return yield binding_media_type.handler
            end
            return fallback.use_fallback_chain(options) {|fb| yield fb} if fallback
            raise EPUB::MediaType::UnsupportedError
          end

          protected

          def traverse_fallback_chain(chain)
            chain << self
            return chain unless fallback
            fallback.traverse_fallback_chain(chain)
          end
        end
      end
    end
  end
end
