require "nokogiri"

module EPUB
  class Parser
    module NokogiriAttributeWithPrefix
      refine Nokogiri::XML::Node do
        def attribute_with_prefix(name, prefix = nil)
          attribute_with_ns(name, EPUB::NAMESPACES[prefix])&.value
        end
      end
    end
  end
end
