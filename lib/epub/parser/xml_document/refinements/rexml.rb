require "rexml/document"

module EPUB
  class Parser
    class XMLDocument
      module Refinements
        module REXML
          [::REXML::Element, ::REXML::Text].each do |klass|
            refine klass do
              %i[document element text].each do |type|
                define_method "#{type}?" do
                  node_type == type
                end
              end
            end
          end

          refine ::REXML::Element do
            def each_element_by_xpath(xpath, namespaces = nil, &block)
              ::REXML::XPath.each self, xpath, namespaces, &block
            end

            def attribute_with_prefix(name, prefix = nil)
              attribute(name, EPUB::NAMESPACES[prefix])&.value
            end

            alias namespace_uri namespace

            def content
              each_child.inject("") {|text, node|
                case node.node_type
                when :document, :element
                  text << node.content
                when :text
                  text << node.value
                end
              }
            end
          end

          refine ::REXML::Text do
            alias content value
          end
        end

        include REXML
      end
    end
  end
end
