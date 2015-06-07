require 'epub/searcher/result'
require 'epub/searcher/publication'
require 'epub/searcher/xhtml'

module EPUB
  module Searcher
    class << self
      # @todo Use named argument in the future
      def search(epub, word, options={algorithm: :seamless})
        Publication.search(epub.package, word, options)
      end
    end
  end
end
