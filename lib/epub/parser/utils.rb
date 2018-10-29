require "rexml/document"
require "nokogiri"

module EPUB
  class Parser
    module REXMLRefinements
      refine REXML::Element do
        def each_element_by_xpath(xpath, namespaces = nil, &block)
          REXML::XPath.each self, xpath, namespaces, &block
        end
      end
    end

    module NokogiriAttributeWithPrefix
      refine Nokogiri::XML::Node do
        def attribute_with_prefix(name, prefix = nil)
          attribute_with_ns(name, EPUB::NAMESPACES[prefix])&.value
        end
      end
    end
  end
end
