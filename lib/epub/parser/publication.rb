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
      end

      def parse_metadata
        raise 'still not implemented'
      end

      def parse_manifest
        manifest = EPUB::Publication::Package::Manifest.new
        elem = @doc.xpath('/xmlns:package/xmlns:manifest', @doc.namespaces).first
        manifest.id = elem['id']

        manifest.items = elem.xpath('./xmlns:item').collect do |elm|
          item = EPUB::Publication::Package::Manifest::Item.new
          item.id = elm['id']
          item.href = elm['href']
          item.media_type = elm['media-type']
          item.fallback = elm['fallback']
          item.properties = elm['properties'] ? elm['properties'].split(' ') : []
          item.media_overlay = elm['media-overlay']
          item
        end
        @package.manifest = manifest
      end

      def parse_spine
        spine = EPUB::Publication::Package::Spine.new

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
