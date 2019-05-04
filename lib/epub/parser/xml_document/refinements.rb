require "rexml/document"

module EPUB
  class Parser
    class XMLDocument
      module Refinements
        [REXML::Element, REXML::Text].each do |klass|
          refine klass do
            %i[document element text].each do |type|
              define_method "#{type}?" do
                node_type == type
              end
            end
          end
        end

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

        if const_defined? :Nokogiri
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
