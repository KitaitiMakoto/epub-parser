require 'epub/publication'

module EPUB
  module Searcher
    class Publication
      class << self
        def search_text(package, word, **options)
          new(package).search_text(word, options)
        end

        def search_element(package, css: nil, xpath: nil, namespaces: {})
          new(package).search_element(css: css, xpath: xpath, namespaces: namespaces)
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
          XHTML::ALGORITHMS[algorithm].search_text(Nokogiri.XML(itemref.item.read), word).each do |sub_result|
            results << Result.new([spine_step, itemref_step] + sub_result.parent_steps, sub_result.start_steps, sub_result.end_steps)
          end
        end

        results
      end

      # @todo: Refactoring
      def search_element(css: nil, xpath: nil, namespaces: {})
        raise ArgumentError, 'Both css and xpath are nil' if css.nil? && xpath.nil?

        namespaces = EPUB::NAMESPACES.merge(namespaces)
        results = []

        spine_step = EPUB::CFI::Step.new(EPUB::Publication::Package::CONTENT_MODELS.index(:spine) * 2)
        @package.spine.each_itemref.with_index do |itemref, index|
          assertion = itemref.id ? EPUB::CFI::IDAssertion.new(itemref.id) : nil
          itemref_step = EPUB::CFI::Step.new((index + 1) * 2, assertion)
          path_to_itemref = EPUB::CFI::Path.new([spine_step, itemref_step])
          content_document = itemref.item.content_document
          next unless content_document
          doc = content_document.nokogiri
          elems = if xpath
                    doc.xpath(xpath, namespaces)
                  else
                    doc.css(css)
                  end
          elems.each do |elem|
            path = find_path(elem)
            results << EPUB::CFI::Location.new([path_to_itemref, path])
          end
        end

        results
      end

      private

      def find_path(elem)
        steps = []
        until elem.parent.document?
          index = elem.parent.element_children.index(elem)
          assertion = elem["id"] ? EPUB::CFI::IDAssertion.new(elem["id"]) : nil
          steps.unshift EPUB::CFI::Step.new((index + 1) * 2, assertion)
          elem = elem.parent
        end
        EPUB::CFI::Path.new(steps)
      end
    end
  end
end
