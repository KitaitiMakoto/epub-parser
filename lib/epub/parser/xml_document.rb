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

%i[Nokogiri Oga REXML].each do |backend|
  begin
    require "epub/parser/xml_document/refinements/#{backend.downcase}"
    EPUB::Parser::XMLDocument.backend ||= backend
  rescue LoadError
  end
end
