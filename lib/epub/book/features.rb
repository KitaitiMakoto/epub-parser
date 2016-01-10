require 'forwardable'

module EPUB
  class Book
    # @!attribute ocf
    #   When writing, sets +ocf.book+ to self.
    #   @return [OCF]
    # @!attribute package
    #   When writing, sets +ocf.book+ to self.
    #   @return [Publication::Package]
    module Features
      extend Forwardable
      modules = [:ocf, :package]
      attr_reader *modules
      attr_accessor :epub_file
      modules.each do |mod|
        define_method "#{mod}=" do |obj|
          instance_variable_set "@#{mod}", obj
          obj.book = self
        end
      end

      def_delegators :package, *Publication::Package::CONTENT_MODELS
      def_delegators :metadata, :title, :main_title, :subtitle, :short_title, :collection_title, :edition_title, :extended_title, :description, :date, :unique_identifier, :modified
      def_delegators :manifest, :nav, :cover_image

      def release_identifier
        "#{unique_identifier}@#{modified}"
      end

      def container_adapter
        @adapter || OCF::PhysicalContainer.adapter
      end

      def container_adapter=(adapter)
        @adapter = adapter.instance_of?(Class) ? adapter : OCF::PhysicalContainer.const_get(adapter)
        adapter
      end

      # @overload each_page_on_spine(&blk)
      #   iterate over items in order of spine when block given
      #   @yieldparam item [Publication::Package::Manifest::Item]
      # @overload each_page_on_spine
      #   @return [Enumerator] which iterates over {Publication::Package::Manifest::Item}s in order of spine when block not given
      def each_page_on_spine(&blk)
        enum = package.spine.items
        if block_given?
          enum.each &blk
        else
          enum.each
        end
      end

      def each_page_on_toc(&blk)
        raise NotImplementedError
      end

      # @overload each_content(&blk)
      #   iterate all items over when block given
      #   @yieldparam item [Publication::Package::Manifest::Item]
      # @overload each_content
      #   @return [Enumerator] which iterates over all {Publication::Package::Manifest::Item}s in EPUB package when block not given
      def each_content(&blk)
        enum = manifest.items
        if block_given?
          enum.each &blk
        else
          enum.to_enum
        end
      end

      def other_navigation
        raise NotImplementedError
      end

      # @return [Array<Publication::Package::Manifest::Item>] All {Publication::Package::Manifest::Item}s in EPUB package
      def resources
        manifest.items
      end

      # Syntax sugar
      def rootfile_path
        ocf.container.rootfile.full_path.to_s
      end
    end
  end
end
