require "epub/parser/cfi"

module EPUB
  class Query
    class EPUBCFI < self
      def initialize(query)
        if query.kind_of?(EPUB::CFI::Location) || query.kind_of?(EPUB::CFI::Range)
          @query = query
        else
          @query = EPUB::Parser::CFI.parse(query)
        end
      end

      # @params package [Publication::Package]
      # @return Array<Hash>
      def query(package)
        if @query.kind_of?(CFI::Location) && @query.paths.last.offset or
           @query.kind_of?(CFI::Range) && (@query.begin.paths.last.offset || @query.end.paths.last.offset)
           ensure_xml_range
        end
        content = extract_content(package, @query)
        [{
          "cfi" => @query,
          "part" => content
        }]
      end

      private

      def ensure_xml_range
        return if Nokogiri::XML.const_defined?(:Range, false)
        require "nokogiri/xml/range"
      rescue LoadError => error
        raise error.exception("Can't load Nokogiri::XML::Range. Try gem install nokogiri-xml-range")
      end

      def extract_content(package, cfi)
        if cfi.kind_of? EPUB::CFI::Location
          node = get_element(cfi, package)
          return unless node
          offset = cfi.paths.last.offset
          offset = offset.value if offset
          # Maybe offset may not be used
          return node
        end

        start_node = get_element(cfi.first, package)
        return unless start_node
        # Need more consideration
        start_node = start_node.children.first if start_node.element?

        end_node = get_element(cfi.last, package)
        return unless end_node
        # Need more consideration
        end_node = end_node.children.last if end_node.element?

        start_offset = cfi.first.paths.last.offset
        start_offset = start_offset ? start_offset.value : 0
        end_offset = cfi.last.paths.last.offset
        end_offset = end_offset ? end_offset.value : 0

        range = Nokogiri::XML::Range.new(start_node, start_offset, end_node, end_offset)

        return range
      end

      def get_element(cfi, package)
        path_in_package = cfi.paths.first
        step_to_itemref = path_in_package.steps[1]
        itemref = package.spine.itemrefs[step_to_itemref.step / 2 - 1]

        document = itemref.item.content_document
        unless document
          warn "Can't load document for item: #{itemref.item.href}"
          return
        end
        doc = document.nokogiri
        path_in_doc = cfi.paths[1]
        current_node = doc.root
        path_in_doc.steps.each do |step|
          if step.element?
            current_node = current_node.element_children[step.value / 2 - 1]
          else
            element_index = (step.value - 1) / 2 - 1
            if element_index == -1
              current_node = current_node.children.first
            else
              prev = current_node.element_children[element_index]
              break unless prev
              current_node = prev.next_sibling
              break unless current_node
            end
          end
        end

        current_node
      end
    end
  end
end
