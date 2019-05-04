require "epub/parser/xml_document/refinements/rexml"

module EPUB
  class Parser
    class XMLDocument
      module Refinements
        include REXML

        if const_defined? :Nokogiri
          require "epub/parser/xml_document/refinements/nokogiri"
          include Nokogiri
        end
      end
    end
  end
end
