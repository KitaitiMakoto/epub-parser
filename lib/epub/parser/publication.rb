require 'nokogiri'
require 'epub/publication'

module EPUB
  class Parser
    class Publication
      class << self
        def parse(file)
          new(file).parse
        end
      end

      def initialize(file)
        @package = EPUB::Publication::Package.new
        @doc = Nokogiri.XML open(file)
      end

      def parse
        # parse_metadata
        parse_manifest
        parse_spine
        # parse_guide
        # parse_bindings

        @package
      end

      def parse_metadata
        raise 'still not implemented'
      end

      def parse_manifest
        manifest = @package.manifest = EPUB::Publication::Package::Manifest.new
        elem = @doc.xpath('/xmlns:package/xmlns:manifest', @doc.namespaces).first
        manifest.id = elem['id']

        elem.xpath('./xmlns:item').each do |elm|
          item = EPUB::Publication::Package::Manifest::Item.new
          %w[ id href media-type fallback media-overlay ].each do |attr|
            item.send "#{attr.gsub(/-/, '_')}=", elm[attr]
          end
          item.properties = elm['properties'] ? elm['properties'].split(' ') : []
          manifest << item
        end

        manifest
      end

      def parse_spine
        spine = @package.spine = EPUB::Publication::Package::Spine.new
        elem = @doc.xpath('/xmlns:package/xmlns:spine', @doc.namespaces).first
        %w[ id toc page-progression-direction ].each do |attr|
          spine.send("#{attr.gsub(/-/, '_')}=", elem[attr])
        end

        elem.xpath('./xmlns:itemref', @doc.namespaces).each do |elm|
          itemref = EPUB::Publication::Package::Spine::Itemref.new
          %w[ idref linear id ].each do |attr|
            itemref.send "#{attr}=", elm[attr]
          end
          itemref.properties = elm['properties'] ? elm['properties'].split(' ') : []
          spine << itemref
        end

        spine
      end

      def parse_guide
        raise 'still not implemented'
      end

      def parse_bindings
        raise 'still not implemented'
      end
    end
  end
end
