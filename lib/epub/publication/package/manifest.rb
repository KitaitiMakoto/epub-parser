require 'enumerabler'
require 'epub/constants'

module EPUB
  module Publication
    class Package
      class Manifest
        attr_accessor :package,
                      :id

        # syntax sugar for #items.<<
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
          @items.collect {|id, item| item}
        end

        def [](item_id)
          @items[item_id]
        end

        class Item
          attr_accessor :manifest,
                        :id, :href, :media_type, :fallback, :properties, :media_overlay,
                        :iri

          # To do: Handle circular fallback chain
          def fallback_chain
            return @fallback_chain if @fallback_chain
            @fallback_chain = traverse_fallback_chain([])
          end

          def read
            open(iri) {|file| file.read}
          end

          # To do: Handle circular fallback chain
          def use_fallback_chain(options = {})
            supported = EPUB::MediaType::CORE
            if ad = options[:supported]
              supported = supported | (ad.respond_to?(:to_ary) ? ad : [ad])
            end
            if del = options[:not_supported]
              supported = supported - (del.respond_to?(:to_ary) ? del : [del])
            end

            if supported.include? media_type
              yield self
            elsif fallback
              fallback.use_fallback_chain(options) {|fallbacked| yield fallbacked}
            else
              raise EPUB::MediaType::NotSupportedError
            end
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
