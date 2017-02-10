require 'epub/searcher/result'
require 'epub/searcher/publication'
require 'epub/searcher/xhtml'

module EPUB
  module Searcher
    class << self
      def search_text(epub, word, **options)
        Publication.search_text(epub.package, word, options)
      end

      def search_element(epub, css: nil, xpath: nil, namespaces: {})
        Publication.search_element(epub.package, css: css, xpath: xpath, namespaces: namespaces)
      end

      def search_by_cfi(epub, cfi)
        Publication.search_by_cfi(epub.package, cfi)
      end
    end
  end
end
