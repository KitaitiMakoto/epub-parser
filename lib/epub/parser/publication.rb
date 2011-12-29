require 'nokogiri'
require 'addressable/uri'
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
        @rootfile = Addressable::URI.parse File.realpath(file)
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

        fallback_map = {}
        elem.xpath('./xmlns:item').each do |elm|
          item = EPUB::Publication::Package::Manifest::Item.new
          %w[ id media-type media-overlay ].each do |attr|
            item.send "#{attr.gsub(/-/, '_')}=", elm[attr]
          end
          # item.href = Addressable::URI.parse elm['href']
          item.href = @rootfile.join Addressable::URI.parse(elm['href'])
          fallback_map[elm['fallback']] = item if elm['fallback']
          item.properties = elm['properties'] ? elm['properties'].split(' ') : []
          manifest << item
        end
        fallback_map.each_pair do |id, from|
          from.fallback = manifest[id]
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
          %w[ idref id ].each do |attr|
            itemref.send "#{attr}=", elm[attr]
          end
          itemref.linear = !(elm['linear'] == 'no')
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
