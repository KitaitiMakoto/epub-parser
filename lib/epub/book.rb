require 'epub/ocf'
require 'epub/publication'
require 'epub/content_document'

module EPUB
  class Book
    attr_accessor :ocf, :package, :content_document

    # For enumerator
    def manifest
    end

    def each_page_by_spine
      @package.spine.items
    end

    def toc
    end

    def each_content
    end

    def other_navigation
    end

    # Syntax suger
    def rootfile_path
      ocf.container.rootfile.full_path
    end
  end
end
