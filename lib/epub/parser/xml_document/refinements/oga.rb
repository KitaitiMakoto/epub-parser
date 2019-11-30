require "oga"

module EPUB
  class Parser
    class XMLDocument
      module Refinements
        module Oga
          refine ::Oga::XML::Traversal do
            def root
              root_node.children.find(&:element?)
            end

            def elements
              children.select(&:element?)
            end
          end

          [::Oga::XML::Document, ::Oga::XML::Node].each do |klass|
            refine klass do
              [
                [:document, ::Oga::XML::Document],
                [:element, ::Oga::XML::Element],
                [:text, ::Oga::XML::Text]
              ].each do |(type, klass)|
                define_method "#{type}?" do
                  kind_of? klass
                end
              end
            end
          end

          refine ::Oga::XML::Document do
            def each_element_by_xpath(xpath, namespaces = nil, &block)
              xpath(xpath, namespaces: namespaces).each &block
            end
          end

          refine ::Oga::XML::Element do
            def each_element_by_xpath(xpath, namespaces = nil, &block)
              xpath(xpath, namespaces: namespaces).each &block
            end

            def attribute_with_prefix(name, prefix = nil)
              name = prefix ? "#{prefix}:#{name}" : name
              get(name)
            end

            def each_element(xpath = nil, &block)
              each_node do |node|
                throw :skip_children unless node.kind_of?(::Oga::XML::Element)
                block.call node
              end
            end

            def namespace_uri
              namespace&.uri
            end

            alias content text
          end

          refine ::Oga::XML::Text do
            alias content text
          end

          refine ::Oga::XML::Namespace do
            alias to_str uri
          end
        end

        include Oga
      end
    end
  end
end
