require 'strscan'
require 'zipruby'
require 'nokogiri'
require 'addressable/uri'
require 'epub/publication'
require 'epub/constants'

module EPUB
  class Parser
    class Publication
      include Utils

      class << self
        def parse(zip_archive, file)
          opf = zip_archive.fopen(Addressable::URI.unencode(file)).read
          new(opf, file).parse
        end
      end

      def initialize(opf, rootfile)
        @package = EPUB::Publication::Package.new
        @rootfile = Addressable::URI.parse(rootfile)
        @doc = Nokogiri.XML(opf)
      end

      def parse
        ([:package] + EPUB::Publication::Package::CONTENT_MODELS).each do |model|
          __send__ "parse_#{model}"
        end

        @package
      end

      def parse_package
        elem = @doc.root
        %w[version xml:lang dir id].each do |attr|
          @package.__send__ "#{attr.gsub(/\:/, '_')}=", extract_attribute(elem, attr)
        end
        @unique_identifier_id = elem['unique-identifier']
        @package.prefix = parse_prefix(extract_attribute(elem, 'prefix'))
        EPUB::Publication.__send__ :include, EPUB::Publication::FixedLayout if @package.prefix.key? EPUB::Publication::FixedLayout::PREFIX_KEY

        @package
      end

      def parse_metadata
        metadata = @package.metadata = EPUB::Publication::Package::Metadata.new
        elem = @doc.xpath('/opf:package/opf:metadata', EPUB::NAMESPACES).first
        id_map = {} # Can this an attribute of EPUB::Package::Metadata or Manifest?

        metadata.identifiers = extract_dcmes(elem, './dc:identifier', id_map, :Identifier, ['id']) {|identifier, e|
          identifier.scheme = extract_attribute(e, 'scheme', 'opf')
          metadata.unique_identifier = identifier if identifier.id == @unique_identifier_id
        }

        metadata.titles = extract_dcmes(elem, './dc:title', id_map, :Title)

        metadata.languages = extract_dcmes(elem, './dc:language', id_map, :DCMES, %w[id])

        %w[ contributor coverage creator date description format publisher relation source subject type ].each do |dcmes|
          metadata.__send__ "#{dcmes}s=", collect_dcmes(elem, "./dc:#{dcmes}")
          metadata.__send__("#{dcmes}s").each {|d| id_map[d.id] = {metadata: d} if d.respond_to?(:id) && d.id}
        end

        metadata.rights = collect_dcmes(elem, './dc:rights')
        metadata.rights.each {|r| id_map[r.id] = {metadata: r} if r.respond_to?(:id) && r.id}

        metadata.metas = elem.xpath('./opf:meta', EPUB::NAMESPACES).collect do |e|
          meta = EPUB::Publication::Package::Metadata::Meta.new
          %w[property id scheme].each do |attr|
            meta.__send__ "#{attr}=", extract_attribute(e, attr)
          end
          meta.content = e.content
          refines = extract_attribute(e, 'refines')
          if refines && refines[0] == '#'
            id = refines[1..-1]
            id_map[id] ||= {}
            id_map[id][:refiners] ||= []
            id_map[id][:refiners] << meta
          end

          meta
        end
        metadata.metas.each {|m| id_map[m.id] = {metadata: m} if m.respond_to?(:id) && m.id}

        metadata.links = elem.xpath('./opf:link', EPUB::NAMESPACES).collect do |e|
          link = EPUB::Publication::Package::Metadata::Link.new
          %w[ id media-type ].each do |attr|
            link.__send__ (attr.gsub(/-/, '_') + '='), extract_attribute(e, attr)
          end
          link.href = Addressable::URI.parse(extract_attribute(e, 'href'))
          link.rel = extract_attribute(e, 'rel').strip.split
          refines = extract_attribute(e, 'refines')
          if refines && refines[0] == '#'
            id = refines[1..-1]
            id_map[id] ||= {}
            id_map[id][:refiners] ||= []
            id_map[id][:refiners] << link
          end

          link
        end
        metadata.links.each {|l| id_map[l.id] = {metadata: l} if l.respond_to?(:id) && l.id}

        id_map.values.each do |hsh|
          next unless hsh[:refiners]
          next unless hsh[:metadata]
          hsh[:refiners].each {|meta| meta.refines = hsh[:metadata]}
        end

        metadata
      end

      def parse_manifest
        manifest = @package.manifest = EPUB::Publication::Package::Manifest.new
        elem = @doc.xpath('/opf:package/opf:manifest', EPUB::NAMESPACES).first
        manifest.id = extract_attribute(elem, 'id')

        fallback_map = {}
        elem.xpath('./opf:item', EPUB::NAMESPACES).each do |e|
          item = EPUB::Publication::Package::Manifest::Item.new
          %w[ id media-type media-overlay ].each do |attr|
            item.__send__ "#{attr.gsub(/-/, '_')}=", extract_attribute(e, attr)
          end
          item.href = Addressable::URI.parse(extract_attribute(e, 'href'))
          fallback = extract_attribute(e, 'fallback')
          fallback_map[fallback] = item if fallback
          properties = extract_attribute(e, 'properties')
          item.properties = properties.split(' ') if properties
          manifest << item
        end
        fallback_map.each_pair do |id, from|
          from.fallback = manifest[id]
        end

        manifest
      end

      def parse_spine
        spine = @package.spine = EPUB::Publication::Package::Spine.new
        elem = @doc.xpath('/opf:package/opf:spine', EPUB::NAMESPACES).first
        %w[ id toc page-progression-direction ].each do |attr|
          spine.__send__ "#{attr.gsub(/-/, '_')}=", extract_attribute(elem, attr)
        end

        elem.xpath('./opf:itemref', EPUB::NAMESPACES).each do |e|
          itemref = EPUB::Publication::Package::Spine::Itemref.new
          %w[ idref id ].each do |attr|
            itemref.__send__ "#{attr}=", extract_attribute(e, attr)
          end
          itemref.linear = (extract_attribute(e, 'linear') != 'no')
          properties = extract_attribute(e, 'properties')
          itemref.properties = properties.split(' ') if properties
          spine << itemref
        end

        spine
      end

      def parse_guide
        guide = @package.guide = EPUB::Publication::Package::Guide.new
        @doc.xpath('/opf:package/opf:guide/opf:reference', EPUB::NAMESPACES).each do |ref|
          reference = EPUB::Publication::Package::Guide::Reference.new
          %w[ type title ].each do |attr|
            reference.__send__ "#{attr}=", extract_attribute(ref, attr)
          end
          reference.href = Addressable::URI.parse(extract_attribute(ref, 'href'))
          guide << reference
        end

        guide
      end

      def parse_bindings
        bindings = @package.bindings = EPUB::Publication::Package::Bindings.new
        @doc.xpath('/opf:package/opf:bindings/opf:mediaType', EPUB::NAMESPACES).each do |elem|
          media_type = EPUB::Publication::Package::Bindings::MediaType.new
          media_type.media_type = extract_attribute(elem, 'media-type')
          media_type.handler = @package.manifest[extract_attribute(elem, 'handler')]
          bindings << media_type
        end

        bindings
      end

      def parse_prefix(str)
        prefixes = {}
        return prefixes if str.nil? or str.empty?
        scanner = StringScanner.new(str)
        scanner.scan /\s*/
        while prefix = scanner.scan(/[^\:\s]+/)
          scanner.scan /[\:\s]+/
          iri = scanner.scan(/[^\s]+/)
          if iri.nil? or iri.empty?
            warn "no IRI detected for prefix `#{prefix}`"
          else
            prefixes[prefix] = iri
          end
          scanner.scan /\s*/
        end
        prefixes
      end

      def extract_dcmes(elem, xpath, id_map, klass=:DCMES, attributes=%w[id lang dir])
        dcmeses = elem.xpath(xpath, EPUB::NAMESPACES).collect do |e|
          dcmes = EPUB::Publication::Package::Metadata.const_get(klass).new
          attributes.each do |attr|
            dcmes.__send__ "#{attr}=", extract_attribute(e, attr)
          end
          dcmes.content = e.content

          yield dcmes, e if block_given?

          dcmes
        end

        dcmeses.each do |dcmes|
          id_map[dcmes.id] = {metadata: dcmes} if dcmes.respond_to?(:id) && dcmes.id
        end

        dcmeses
      end

      def collect_dcmes(elem, selector)
        elem.xpath(selector, EPUB::NAMESPACES).collect do |e|
          md = EPUB::Publication::Package::Metadata::DCMES.new
          md.content = e.content
          %w[ id lang dir ].each do |attr|
            md.__send__ "#{attr}=", extract_attribute(e, attr)
          end
          yield(md, e) if block_given?
          md
        end
      end
    end
  end
end
