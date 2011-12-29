require 'epub/content_document'
require 'epub/constants'
require 'nokogiri'

module EPUB
  class Parser
    class ContentDocument
      class << self
        def parse(root_directory)
          new(root_directory).parse
        end
      end

      def initialize(root_directory)
        @dir = root_directory
      end

      def parse
        raise 'Not implemented yet'
      end

      # @param [Nokogiri::HTML::Document] document HTML document or element including nav
      # @return [Array<EPUB::ContentDocument::Navigation::Nav>] navs array of Nav object
      def parse_navigations(document)
        navs = document.search('/xhtml:html/xhtml:body//xhtml:nav', EPUB::NAMESPACES).collect {|elem| parse_navigation elem}
      end

      # @param [Nokogiri::XML::Element] nav nav element
      # @return [EPUB::ContentDocument::Navigation::Nav] nav Nav object
      def parse_navigation(element)
        nav = EPUB::ContentDocument::Navigation::Nav.new
        nav.heading = find_heading element

        # to find type, need to use strict xpath for handling namespaces?
        # And if so, where should the namespaces be defined?
        # nav.type = element['epub:type']
        element.namespaces['epub'] = "http://www.idpf.org/2007/ops"
        p element.namespaces
        nav.type = element['epub:type']
        p nav.type

        nav
      end

      private

      # @param [Nokogiri::XML::Element] nav nav element
      # @return [String] heading heading text
      def find_heading(element)
        heading = element.xpath('./xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6|xhtml:hgroup', EPUB::NAMESPACES).first

        return nil if heading.nil?
        return heading.text unless heading.name == 'hgroup'

        (heading/'h1' || heading/'h2' || heading/'h3' || heading/'h4' || heading/'h5' || heading/'h6').first.text
      end
    end
  end
end
