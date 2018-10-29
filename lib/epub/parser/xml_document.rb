require "rexml/document"
begin
  require "nokogiri"
rescue LoadError
end

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

      module Refinements
        [REXML::Element, REXML::Text].each do |klass|
          refine klass do
            def document?
              node_type == :document
            end

            def element?
              node_type == :element
            end

            def text?
              node_type == :text
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

            def namespace_uri
              namespace.href
            end
          end
        end
      end
    end
  end
end
