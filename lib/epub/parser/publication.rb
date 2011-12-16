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
        @file = file
        @package = EPUB::Publication::Package.new
      end

      def parse
        raise 'still not implemented'
      end

      def parse_manifest
        manifest = EPUB::Publication::Package::Manifest.new
        doc = Nokogiri.XML open(@file)
        p doc
      end
    end
  end
end
