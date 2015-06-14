module EPUB
  class Parser
    module Utils
      # Extract the value of attribute of element
      # 
      # @todo Refinement Nokogiri::XML::Node instead of use this method after Ruby 2.0 becomes popular
      # 
      # @param [Nokogiri::XML::Element] element
      # @param [String] name name of attribute excluding namespace prefix
      # @param [String, nil] prefix XML namespace prefix in {EPUB::NAMESPACES} keys
      # @return [String] value of attribute when the attribute exists
      # @return nil when the attribute doesn't exist
      def extract_attribute(element, name, prefix=nil)
        attr = element.attribute_with_ns(name, EPUB::NAMESPACES[prefix])
        attr.nil? ? nil : attr.value
      end
      module_function :extract_attribute
    end
  end
end
