module EPUB
  module ContentDocument
    class XHTML
      attr_accessor :item

      # @param [Boolean] detect_encoding See {Publication::Package::Manifest::Item#read}
      # @return [String] Returns the content string.
      def read(detect_encoding: true)
        item.read(detect_encoding: detect_encoding)
      end
      alias raw_document read

      # @return [true|false] Whether referenced directly from spine or not.
      def top_level?
        !! item.itemref
      end

      # @return [String] Returns the value of title element.
      #                  If none, returns empty string
      def title
        title_elem = rexml.get_elements('.//title').first
        if title_elem
          title_elem.text
        else
          warn 'title element not found'
          ''
        end
      end

      # @return [REXML::Document] content as REXML::Document object
      def rexml
        @rexml ||= REXML::Document.new(raw_document)
      end

      # @return [Oga::XML::Document] content as Oga::XML::Document object
      def oga
        require "oga"
        @oga ||= Oga.parse_xml(raw_document)
      end

      # @return [Nokogiri::XML::Document] content as Nokogiri::XML::Document object
      def nokogiri
        require 'nokogiri'
        @nokogiri ||= Nokogiri.XML(raw_document)
      end
    end
  end
end
