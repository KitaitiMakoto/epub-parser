module EPUB
  module ContentDocument
    class XHTML
      attr_accessor :book

      def read
      end
      alias raw_document read
    end
  end
end
