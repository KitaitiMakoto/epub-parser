module EPUB
  class Query
    class CSSSelector < self
      # @param package [Publication::Package]
      # @return Enumerator
      def query(package)
        enum_for(:_query, package)
      end

      private

      def _query(package)
        spine_step = CFI::Step.new(6)
        package.spine.each_itemref.with_index do |itemref, index|
          next unless itemref.item.xhtml?
          assertion = itemref.id ? CFI::IDAssertion.new(itemref.id) : nil
          itemref_step = CFI::Step.new((index + 1) * 2, assertion)
          path_to_itemref = CFI::Path.new([spine_step, itemref_step])
          document = itemref.item.content_document
          unless document
            warn "Can't load document for item: #{item.href}"
            next
          end
          document.nokogiri.css(@query).each do |elem|
            path = find_path(elem)
            location = CFI::Location.new([path_to_itemref, path])
            result = {"cfi" => location, "part" => elem}
            yield result
          end
        end
      end

      def find_path(elem)
        steps = []
        until elem.parent.document?
          index = elem.parent.element_children.index(elem)
          assertion = elem["id"] ? CFI::IDAssertion.new(elem["id"]) : nil
          steps.unshift CFI::Step.new((index + 1) * 2, assertion)
          elem = elem.parent
        end
        EPUB::CFI::Path.new(steps)
      end
    end
  end
end
