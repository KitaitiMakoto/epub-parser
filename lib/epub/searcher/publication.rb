require 'epub/publication'
require "epub/parser/xml_document"

module EPUB
  module Searcher
    class Publication
      using Parser::XMLDocument::Refinements

      class << self
        def search_text(package, word, **options)
          new(package).search_text(word, options)
        end

        def search_element(package, css: nil, xpath: nil, namespaces: {})
          new(package).search_element(css: css, xpath: xpath, namespaces: namespaces)
        end

        def search_by_cfi(package, cfi)
          new(package).search_by_cfi(cfi)
        end
      end

      def initialize(package)
        @package = package
      end

      def search_text(word, algorithm: :seamless)
        results = []

        spine = @package.spine
        spine_step = Result::Step.new(:element, 2, {:name => 'spine', :id => spine.id})
        spine.each_itemref.with_index do |itemref, index|
          itemref_step = Result::Step.new(:itemref, index, {:id => itemref.id})
          XHTML::ALGORITHMS[algorithm].search_text(Parser::XMLDocument.new(itemref.item.read), word).each do |sub_result|
            results << Result.new([spine_step, itemref_step] + sub_result.parent_steps, sub_result.start_steps, sub_result.end_steps)
          end
        end

        results
      end

      # @todo: Refactoring
      # @return [Array<Hash>] An array of rearch results. Each result is composed of:
      #   :element: [REXML::Element, Nokogiri::XML::ELement] Found element
      #   :itemref: [EPUB::Publication::Package::Spine::Itemref] Itemref that element's document belongs to
      #   :location: [EPUB::CFI::Location] CFI that indicates the element
      #   :package: [EPUB::Publication::Package] Package that the element belongs to
      def search_element(css: nil, xpath: nil, namespaces: {})
        raise ArgumentError, 'Both css and xpath are nil' if css.nil? && xpath.nil?

        namespaces = EPUB::NAMESPACES.merge(namespaces)
        results = []

        spine_step = EPUB::CFI::Step.new((EPUB::Publication::Package::CONTENT_MODELS.index(:spine) + 1) * 2)
        @package.spine.each_itemref.with_index do |itemref, index|
          assertion = itemref.id ? EPUB::CFI::IDAssertion.new(itemref.id) : nil
          itemref_step = EPUB::CFI::Step.new((index + 1) * 2, assertion)
          path_to_itemref = EPUB::CFI::Path.new([spine_step, itemref_step])
          content_document = itemref.item.content_document
          next unless content_document
          elems = if xpath
                    doc = Parser::XMLDocument.new(content_document.read)
                    doc.each_element_by_xpath(xpath, namespaces)
                  else
                    begin
                      doc = content_document.nokogiri
                    rescue LoadError
                      raise "#{self.class}##{__method__} with `css` argument requires Nokogiri gem for now. Install Nokogiri and then try again."
                    end
                    doc.css(css)
                  end
          elems.each do |elem|
            path = find_path(elem)
            results << {
              location: EPUB::CFI::Location.new([path_to_itemref, path]),
              package: @package,
              itemref: itemref,
              element: elem
            }
          end
        end

        results
      end

      # @note Currenty can handle only location CFI without offset
      # @todo Use XHTML module
      # @todo Handle CFI with offset
      # @todo Handle range CFI
      # @param [EPUB::CFI] cfi
      # @return [Array] Path in EPUB Rendition
      def search_by_cfi(cfi)
        path_in_package = cfi.paths.first
        spine = @package.spine
        model = [@package.metadata, @package.manifest, spine, @package.guide, @package.bindings].compact[path_in_package.steps.first.value / 2 - 1]
        raise NotImplementedError, "Currently, #{__method__} supports spine only(#{cfi})" unless model == spine
        raise ArgumentError, "Cannot identify <itemref>'s child" if path_in_package.steps.length > 2

        step_to_itemref = path_in_package.steps[1]
        itemref = spine.itemrefs[step_to_itemref.value / 2 - 1]

        doc = itemref.item.content_document.nokogiri
        path_in_doc = cfi.paths[1]
        current_node = doc.root
        path_in_doc.steps.each do |step|
          if step.element?
            current_node = current_node.elements.to_a[step.value / 2 - 1]
          else
            element_index = (step.value - 1) / 2 - 1
            if element_index == -1
              current_node = current_node.children.first
            else
              prev = current_node.elements.to_a[element_index]
              break unless prev
              current_node = prev.next_sibling
              break unless current_node
            end
          end
        end

        raise NotImplementedError, "Currently, #{__method__} doesn't support deeper DOM tree such as including <iframe>" if cfi.paths[2]

        [itemref, current_node]
      end

      private

      def find_path(elem)
        steps = []
        until elem.parent.document?
          index = elem.parent.elements.to_a.index(elem)
          id_attr = elem.attribute_with_prefix("id")
          assertion = id_attr ? EPUB::CFI::IDAssertion.new(id_attr) : nil
          steps.unshift EPUB::CFI::Step.new((index + 1) * 2, assertion)
          elem = elem.parent
        end
        EPUB::CFI::Path.new(steps)
      end
    end
  end
end
