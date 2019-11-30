module EPUB
  class Parser
    class XMLDocument
      class << self
        attr_accessor :backend

        def new(xml)
          case backend
          when :Oga
            Oga.parse_xml(xml)
          when :Nokogiri
            Nokogiri.XML(xml)
          else
            REXML::Document.new(xml)
          end
        end
      end
    end
  end
end

require "epub/parser/xml_document/refinements/rexml"
begin
  require "epub/parser/xml_document/refinements/nokogiri"
  EPUB::Parser::XMLDocument.backend = :Nokogiri
rescue LoadError
  EPUB::Parser::XMLDocument.backend = :REXML
end
