require 'epub/constants'
require 'epub/ocf'
require 'zipruby'
require 'nokogiri'

module EPUB
  class Parser
    class OCF
      include Utils

      DIRECTORY = 'META-INF'
      EPUB::OCF::MODULES.each {|m| self.const_set "#{m.upcase}_FILE", "#{m}.xml"} # Deprecated

      class << self
        def parse(zip_archive)
          new(zip_archive).parse
        end
      end

      def initialize(zip_archive)
        @zip = zip_archive
        @ocf = EPUB::OCF.new
      end

      def parse
        EPUB::OCF::MODULES.each do |m|
          begin
            file = @zip.fopen(File.join(DIRECTORY, "#{m}.xml"))
            @ocf.__send__ "#{m}=", __send__("parse_#{m}", file.read)
          rescue Zip::Error
          end
        end

        @ocf
      end

      def parse_container(xml)
        container = EPUB::OCF::Container.new
        doc = Nokogiri.XML(xml)
        doc.xpath('/ocf:container/ocf:rootfiles/ocf:rootfile', EPUB::NAMESPACES).each do |elem|
          rootfile = EPUB::OCF::Container::Rootfile.new
          rootfile.full_path = Addressable::URI.parse(extract_attribute(elem, 'full-path'))
          rootfile.media_type = extract_attribute(elem, 'media-type')
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
        warn "Not implemented: #{self.class}##{__method__}" if $VERBOSE
      end

      def parse_rights(content)
        warn "Not implemented: #{self.class}##{__method__}" if $VERBOSE
      end

      def parse_signatures(content)
        warn "Not implemented: #{self.class}##{__method__}" if $VERBOSE
      end
    end
  end
end
