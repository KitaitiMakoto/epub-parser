require 'epub/constants'
require 'epub/ocf'
require 'epub/ocf/physical_container'
require 'epub/parser/metadata'
require 'nokogiri'

module EPUB
  class Parser
    class OCF
      using NokogiriAttributeWithPrefix
      include Metadata

      DIRECTORY = 'META-INF'

      class << self
        def parse(container)
          new(container).parse
        end
      end

      def initialize(container)
        @container = container
        @ocf = EPUB::OCF.new
      end

      def parse
        EPUB::OCF::MODULES.each do |m|
          begin
            data = @container.read(File.join(DIRECTORY, "#{m}.xml"))
            @ocf.__send__ "#{m}=", __send__("parse_#{m}", data)
          rescue EPUB::OCF::PhysicalContainer::NoEntry
          end
        end

        @ocf
      end

      def parse_container(xml)
        container = EPUB::OCF::Container.new
        doc = Nokogiri.XML(xml)
        doc.xpath('/ocf:container/ocf:rootfiles/ocf:rootfile', EPUB::NAMESPACES).each do |elem|
          rootfile = EPUB::OCF::Container::Rootfile.new
          rootfile.full_path = Addressable::URI.parse(elem.attribute_with_prefix('full-path'))
          rootfile.media_type = elem.attribute_with_prefix('media-type')
          container.rootfiles << rootfile
        end

        container
      end

      def parse_encryption(content)
        encryption = EPUB::OCF::Encryption.new
        encryption.content = content
        encryption
      end

      def parse_manifest(content)
        warn "Not implemented: #{self.class}##{__method__}" if $VERBOSE
      end

      def parse_metadata(content)
        doc = Nokogiri.XML(content)
        unless multiple_rendition_metadata?(doc)
          warn "Not implemented: #{self.class}##{__method__}" if $VERBOSE
          metadata = EPUB::OCF::UnknownFormatMetadata.new
          metadata.content = content
          return metadata
        end
        super(doc.root, doc.root['unique-identifier'], 'metadata')
      end

      def parse_rights(content)
        warn "Not implemented: #{self.class}##{__method__}" if $VERBOSE
      end

      def parse_signatures(content)
        warn "Not implemented: #{self.class}##{__method__}" if $VERBOSE
      end

      private

      def multiple_rendition_metadata?(doc)
        doc.root &&
          doc.root.name == 'metadata' &&
          doc.namespaces['xmlns'] == EPUB::NAMESPACES['metadata']
      end
    end
  end
end
