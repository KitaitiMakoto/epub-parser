require 'epub/constants'
require 'epub/ocf'
require 'zipruby'
require 'nokogiri'

module EPUB
  class Parser
    class OCF
      DIRECTORY = 'META-INF'
      EPUB::OCF::MODULES.each {|m| self.const_set "#{m.upcase}_FILE", "#{m}.xml"}

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
        container_xml  = @zip.fopen(File.join(DIRECTORY, CONTAINER_FILE)).read
        @ocf.container = parse_container(container_xml)
        (EPUB::OCF::MODULES - ['container']).each do |m|
          @ocf.__send__ "#{m}=", __send__("parse_#{m}")
        end
        @ocf
      end

      def parse_container(xml)
        container = EPUB::OCF::Container.new
        doc = Nokogiri.XML(xml)
        doc.xpath('/ocf:container/ocf:rootfiles/ocf:rootfile', EPUB::NAMESPACES).each do |elem|
          rootfile = EPUB::OCF::Container::Rootfile.new
          %w[full-path media-type].each do |attr|
            rootfile.__send__(attr.gsub(/-/, '_') + '=', elem[attr])
          end
          container.rootfiles << rootfile
        end

        container
      end

      def parse_encryption
        warn "Not implemented: #{self.class}##{__method__}" if $VERBOSE
      end

      def parse_manifest
        warn "Not implemented: #{self.class}##{__method__}" if $VERBOSE
      end

      def parse_metadata
        warn "Not implemented: #{self.class}##{__method__}" if $VERBOSE
      end

      def parse_rights
        warn "Not implemented: #{self.class}##{__method__}" if $VERBOSE
      end

      def parse_signatures
        warn "Not implemented: #{self.class}##{__method__}" if $VERBOSE
      end
    end
  end
end
