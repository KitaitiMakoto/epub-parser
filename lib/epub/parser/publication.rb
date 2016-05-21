require 'strscan'
require 'nokogiri'
require 'epub/publication'
require 'epub/constants'
require 'epub/parser/metadata'

module EPUB
  class Parser
    class Publication
      include Utils
      include Metadata

      class << self
        def parse(container, file)
          opf = container.read(Addressable::URI.unencode(file))

          new(opf, file).parse
        end
      end

      def initialize(opf, rootfile=nil)
        warn "Second argument for #{self.class}.new is deprecated" if rootfile
        @doc = Nokogiri.XML(opf)
      end

      def parse
        package = parse_package(@doc)
        (EPUB::Publication::Package::CONTENT_MODELS - [:bindings]).each do |model|
          package.__send__ "#{model}=",  __send__("parse_#{model}", @doc)
        end
        package.bindings = parse_bindings(@doc, package.manifest)

        package
      end

      def parse_package(doc)
        package = EPUB::Publication::Package.new
        elem = doc.root
        %w[version xml:lang dir id].each do |attr|
          package.__send__ "#{attr.gsub(/\:/, '_')}=", extract_attribute(elem, attr)
        end
        package.prefix = parse_prefix(extract_attribute(elem, 'prefix'))
        EPUB::Publication.__send__ :include, EPUB::Publication::FixedLayout if package.prefix.key? EPUB::Publication::FixedLayout::PREFIX_KEY

        package
      end

      def parse_manifest(doc)
        manifest = EPUB::Publication::Package::Manifest.new
        elem = doc.xpath('/opf:package/opf:manifest', EPUB::NAMESPACES).first
        manifest.id = extract_attribute(elem, 'id')

        fallback_map = {}
        elem.xpath('./opf:item', EPUB::NAMESPACES).each do |e|
          item = EPUB::Publication::Package::Manifest::Item.new
          %w[id media-type media-overlay].each do |attr|
            item.__send__ "#{attr.gsub(/-/, '_')}=", extract_attribute(e, attr)
          end
          item.href = extract_attribute(e, 'href')
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

      def parse_spine(doc)
        spine = EPUB::Publication::Package::Spine.new
        elem = doc.xpath('/opf:package/opf:spine', EPUB::NAMESPACES).first
        %w[id toc page-progression-direction].each do |attr|
          spine.__send__ "#{attr.gsub(/-/, '_')}=", extract_attribute(elem, attr)
        end

        elem.xpath('./opf:itemref', EPUB::NAMESPACES).each do |e|
          itemref = EPUB::Publication::Package::Spine::Itemref.new
          %w[idref id].each do |attr|
            itemref.__send__ "#{attr}=", extract_attribute(e, attr)
          end
          itemref.linear = (extract_attribute(e, 'linear') != 'no')
          properties = extract_attribute(e, 'properties')
          itemref.properties = properties.split(' ') if properties
          spine << itemref
        end

        spine
      end

      def parse_guide(doc)
        guide = EPUB::Publication::Package::Guide.new
        doc.xpath('/opf:package/opf:guide/opf:reference', EPUB::NAMESPACES).each do |ref|
          reference = EPUB::Publication::Package::Guide::Reference.new
          %w[type title].each do |attr|
            reference.__send__ "#{attr}=", extract_attribute(ref, attr)
          end
          reference.href = extract_attribute(ref, 'href')
          guide << reference
        end

        guide
      end

      def parse_bindings(doc, handler_map)
        bindings = EPUB::Publication::Package::Bindings.new
        doc.xpath('/opf:package/opf:bindings/opf:mediaType', EPUB::NAMESPACES).each do |elem|
          media_type = EPUB::Publication::Package::Bindings::MediaType.new
          media_type.media_type = extract_attribute(elem, 'media-type')
          media_type.handler = handler_map[extract_attribute(elem, 'handler')]
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
    end
  end
end
