require "epub/parser/utils"

module EPUB
  class Parser
    class XMLDocument
      class << self
        def new(xml)
          REXML::Document.new(xml)
        end
      end
    end
  end
end
