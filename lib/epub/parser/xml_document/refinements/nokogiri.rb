module EPUB
  class Parser
    class XMLDocument
      module Refinements
        module Nokogiri
          refine ::Nokogiri::XML::Node do
            def each_element_by_xpath(xpath, namespaces = nil, &block)
              xpath(xpath, namespaces).each &block
            end

            def attribute_with_prefix(name, prefix = nil)
              attribute_with_ns(name, EPUB::NAMESPACES[prefix])&.value
            end

            def each_element(xpath = nil, &block)
              element_children.each(&block)
            end

            alias elements element_children

            def namespace_uri
              namespace.href
            end
          end
        end
      end
    end
  end
end
