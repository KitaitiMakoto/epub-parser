%w[ metadata manifest spine guide ].each { |f| require "epub/publication/package/#{f}" }

module EPUB
  module Publication
    class Package
      attr_accessor :version, :unique_identifier, :prefix, :xml_lang, :dir, :id
      attr_reader :metadata, :manifest, :spine, :guide
      alias lang  xml_lang
      alias lang= xml_lang=

      def metadata=(metadata)
      end

      def manifest=(manifest)
        manifest.package = self
        @manifest = manifest
      end

      def spine=(spine)
        spine.package = self
        @spine = spine
      end

      def guide=(guide)
        guide.package = self
        @guide = spine
      end
    end
  end
end
