require 'epub/inspector'
require 'epub/ocf'
require 'epub/publication'
require 'epub/content_document'
require 'epub/book/features'

module EPUB
  class << self
    def included(base)
      warn 'Including EPUB module is deprecated. Include EPUB::Book::Features instead.'
      base.__send__ :include, EPUB::Book::Features
    end
  end
end
