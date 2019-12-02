require "oga"

module EPUB
  class Parser
    class XMLDocument
      module Refinements
        module Oga
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

              def root
                # Couldn't use find(&:element?) for Rubies under 2.6
                root_node.children.find {|child| child.element?}
              end

              def elements
                # Couldn't use find(&:element?) for Rubies under 2.6
                children.select {|child| child.element?}
              end

              # Need for Rubies under 2.6
              def respond_to?(name, include_all = false)
                [:root, :elements].include?(name) || super
              end

              def each_element_by_xpath(xpath, namespaces = nil, &block)
                xpath(xpath, namespaces: namespaces).each &block
              end
            end
          end

          refine ::Oga::XML::Element do
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
