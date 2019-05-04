module EPUB
  class Parser
    class XMLDocument
      class << self
        attr_accessor :backend

        def new(xml)
          if backend == :Nokogiri
            Nokogiri.XML(xml)
          else
            REXML::Document.new(xml)
          end
        end
      end
    end
  end
end

require "epub/parser/xml_document/refinements"
