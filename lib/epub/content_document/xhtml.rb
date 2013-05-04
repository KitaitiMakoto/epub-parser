module EPUB
  module ContentDocument
    class XHTML
      attr_accessor :item

      def read
        item.read
      end
      alias raw_document read

      # referenced directly from spine?
      def top_level?
        !! item.itemref
      end
    end
  end
end
