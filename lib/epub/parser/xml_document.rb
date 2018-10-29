require "rexml/document"
require "nokogiri"

module EPUB
  class Parser
    class XMLDocument
      class << self
        def new(xml)
          REXML::Document.new(xml)
        end
      end

      module Refinements
        refine REXML::Element do
          def each_element_by_xpath(xpath, namespaces = nil, &block)
            REXML::XPath.each self, xpath, namespaces, &block
          end

          def attribute_with_prefix(name, prefix = nil)
            attribute(name, EPUB::NAMESPACES[prefix])&.value
          end

          alias namespace_uri namespace

          def content
            texts.join
          end
        end

        refine REXML::Text do
          alias content value
        end

        refine Nokogiri::XML::Node do
          def each_element_by_xpath(xpath, namespaces = nil, &block)
            xpath(xpath, namespaces).each &block
          end

          def attribute_with_prefix(name, prefix = nil)
            attribute_with_ns(name, EPUB::NAMESPACES[prefix])&.value
          end

          def each_element(xpath = nil, &block)
            element_children.each(&block)
          end

          def namespace_uri
            namespace.href
          end
        end
      end
    end
  end
end
