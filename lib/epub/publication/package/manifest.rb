require 'enumerabler'
require 'epub/constants'
require 'epub/parser/content_document'

module EPUB
  module Publication
    class Package
      class Manifest
        include Inspector::PublicationModel

        attr_accessor :package,
                      :id

        def initialize
          @items = {}
        end

        # @return self
        def <<(item)
          item.manifest = self
          @items[item.id] = item
          self
        end

        def navs
          items.selector(&:nav?)
        end

        def nav
          navs.first
        end

        def cover_image
          items.selector {|i| i.properties.include? 'cover-image'}.first
        end

        def each_item
          @items.each_value do |item|
            yield item
          end
        end

        def items
          @items.values
        end

        def [](item_id)
          @items[item_id]
        end

        class Item
          include Inspector

          # @!attribute [rw] manifest
          #   @return [Manifest] Returns the value of manifest
          # @!attribute [rw] id
          #   @return [String] Returns the value of id
          # @!attribute [rw] href
          #   @return [Addressable::URI] Returns the value of href,
          #                              which is relative path from rootfile(OPF file)
          # @!attribute [rw] media_type
          #   @return [String] Returns the value of media_type
          # @!attribute [rw] properties
          #   @return [Array<String>] Returns the value of properties
          # @!attribute [rw] media_overlay
          #   @return [String] Returns the value of media_overlay
          # @!attribute [rw] fallback
          #   @return [Item] Returns the value of attribute fallback
          attr_accessor :manifest,
                        :id, :href, :media_type, :fallback, :properties, :media_overlay

          def initialize
            @properties = []
          end

          # @todo Handle circular fallback chain
          def fallback_chain
            @fallback_chain ||= traverse_fallback_chain([])
          end

          # full path in archive
          def entry_name
            rootfile = manifest.package.book.ocf.container.rootfile.full_path
            Addressable::URI.unescape(rootfile + href.normalize.request_uri)
          end

          def read
            Zip::Archive.open(manifest.package.book.epub_file) {|zip|
              zip.fopen(entry_name).read
            }
          end

          def xhtml?
            media_type == 'application/xhtml+xml'
          end

          def nav?
            properties.include? 'nav'
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

          def content_document
            return nil unless %w[application/xhtml+xml image/svg+xml].include? media_type
            @content_document ||= Parser::ContentDocument.new(self).parse
          end

          # @return [Package::Spine::Itemref]
          # @return nil when no Itemref refers this Item
          def itemref
            manifest.package.spine.itemrefs.find {|itemref| itemref.idref == id}
          end

          def inspect
            "#<%{class}:%{object_id} %{manifest} %{attributes}>" % {
              :class      => self.class,
              :object_id  => inspect_object_id,
              :manifest   => "@manifest=#{@manifest.inspect_simply}",
              :attributes => inspect_instance_variables(exclude: [:@manifest])
            }
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
