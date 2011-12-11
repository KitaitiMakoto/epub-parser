require 'epub/ocf'
require 'epub/publication'
require 'epub/content_document'

module EPUB
  class Book
    attr_accessor :container, :package, :content_document

    # For enumerator
    def manifest
    end

    def spine
    end

    def toc
    end

    def each_content
    end

    def other_navigation
    end

    def rootfile
      @container.rootfile.full_path
    end
  end
end
