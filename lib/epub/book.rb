require 'epub/ocf'
require 'epub/publication'
require 'epub/content_document'

module EPUB
  class Book
    attr_accessor :ocf, :package, :content_document

    def each_page_by_spine(&blk)
      enum = @package.spine.items
      if block_given?
        enum.each &blk
      else
        enum
      end
    end

    def each_page_by_toc(&blk)
    end

    def each_content(&blk)
      enum = @package.manifest.items
      if block_given?
        enum.each &blk
      else
        enum.to_enum
      end
    end

    def other_navigation
    end

    # Syntax sugar
    def rootfile_path
      ocf.container.rootfile.full_path
    end

    # Syntax sugar
    def cover_image
      package.manifest.cover_image
    end
  end
end
