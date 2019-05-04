require "epub/parser/xml_document/refinements/rexml"

module EPUB
  class Parser
    class XMLDocument
      module Refinements
        if const_defined? :Nokogiri
          require "epub/parser/xml_document/refinements/nokogiri"
        end
      end
    end
  end
end
