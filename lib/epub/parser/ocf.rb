require 'epub/ocf'
require 'nokogiri'

module EPUB
  class Parser
    class OCF
      DIRECTORY = 'META-INF'
      %w[container encryption manifest metadata rights signatures].each do |file|
        self.const_set file.upcase + '_FILE', file + '.xml'
      end

      class << self
        def parse(root_dir)
          new(root_dir).parse
        end
      end

      def initialize(root_dir)
        @dir = root_dir
      end

      def parse
        parse_container
        parse_encryption
        parse_manifest
        parse_metadata
        parse_rights
        pares_signatures
      end

      def parse_container
        container = EPUB::OCF::Container.new
        doc = Nokogiri.XML open(File.join @dir, DIRECTORY, CONTAINER_FILE)

        doc.xpath('/xmlns:container/xmlns:rootfiles/xmlns:rootfile', doc.namespaces).each do |elem|
          rootfile = EPUB::OCF::Container::Rootfile.new
          %w[full-path media-type].each do |attr|
            rootfile.send(attr.gsub(/-/, '_') + '=', elem[attr])
            container.rootfiles << rootfile
          end
        end

        container
      end
    end
  end
end
