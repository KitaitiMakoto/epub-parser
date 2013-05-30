module EPUB
  module ContentDocument
    class XHTML
      attr_accessor :item

      # @return [String] Returns the content string.
      def read
        item.read
      end
      alias raw_document read

      # @return [true|false] Whether referenced directly from spine or not.
      def top_level?
        !! item.itemref
      end

      # @return [String] Returns the value of title element.
      #                  If none, returns empty string
      def title
        title_elem = Nokogiri.XML(read).search('title').first
        if title_elem
          title_elem.text
        else
          warn 'title element not found'
          ''
        end
      end
    end
  end
end
