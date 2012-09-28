module EPUB
  module Publication
    class Package
      CONTENT_MODELS = [:metadata, :manifest, :spine, :guide, :bindings]

      attr_accessor :book,
                    :version, :unique_identifier_id, :prefix, :xml_lang, :dir, :id
      attr_reader *CONTENT_MODELS
      alias lang  xml_lang
      alias lang= xml_lang=

      def metadata=(metadata)
        @metadata.package = nil if @metadata
        metadata.package = self
        @metadata = metadata
      end

      def manifest=(manifest)
        @manifest.package = nil if @manifest
        manifest.package = self
        @manifest = manifest
      end

      def spine=(spine)
        @spine.package = nil if @spine
        spine.package = self
        @spine = spine
      end

      def guide=(guide)
        @guide.package = nil if @guide
        guide.package = self
        @guide = guide
      end

      def bindings=(bindings)
        @bindings.package = nil if @bindings
        bindings.package = self
        @buindings = bindings
      end

      def unique_identifier
        @metadata.unique_identifier
      end
    end
  end
end

EPUB::Publication::Package::CONTENT_MODELS.each do |f|
  require_relative "package/#{f}"
end
