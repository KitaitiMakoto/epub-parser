require "epub/parser"
require "epub/cfi"
require "epub/query/epubcfi"
require "epub/query/css_selector"

module EPUB
  class Query
    def initialize(query)
      @query = query
    end
  end

  module Book::Features
    # @return Enumerator
    def query(query_string, type: "cfi")
      case type
      when "cfi"
        Query::EPUBCFI.new(query_string).query(package)
      when "css"
        Query::CSSSelector.new(query_string).query(package)
      end
    end
  end
end
