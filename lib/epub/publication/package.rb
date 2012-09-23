%w[ metadata manifest spine guide bindings ].each { |f| require "epub/publication/package/#{f}" }

module EPUB
  module Publication
    class Package
      attr_accessor :book,
                    :version, :unique_identifier_id, :prefix, :xml_lang, :dir, :id
      attr_reader :metadata, :manifest, :spine, :guide, :bindings
      alias lang  xml_lang
      alias lang= xml_lang=

      def metadata=(metadata)
        metadata.package = self
        @metadata = metadata
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
        @guide = guide
      end

      def bindings=(bindings)
        bindings.package = self
        @buindings = bindings
      end

      def unique_identifier
        @metadata.unique_identifier
      end
    end
  end
end
