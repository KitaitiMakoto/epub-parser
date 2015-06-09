require 'epub/searcher/result'
require 'epub/searcher/publication'
require 'epub/searcher/xhtml'

module EPUB
  module Searcher
    class << self
      def search(epub, word, **options)
        Publication.search(epub.package, word, options)
      end
    end
  end
end
