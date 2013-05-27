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

      def title
        title_elem = Nokogiri.XML(read).search('title').first
        title_elem ? title_elem.text : ''
      end
    end
  end
end
