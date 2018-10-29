require 'epub/content_document'
require 'epub/constants'
require 'epub/parser/xml_document'
require 'nokogiri'

module EPUB
  class Parser
    class ContentDocument
      using XMLDocument::Refinements

      # @param [EPUB::Publication::Package::Manifest::Item] item
      def initialize(item)
        @item = item
      end

      def parse
        content_document = case @item.media_type
                           when 'application/xhtml+xml'
                             if @item.nav?
                               EPUB::ContentDocument::Navigation.new
                             else
                               EPUB::ContentDocument::XHTML.new
                             end
                           when 'image/svg+xml'
                             EPUB::ContentDocument::SVG.new
                           else
                             nil
                           end
        return content_document if content_document.nil?
        content_document.item = @item
        document = XMLDocument.new(@item.read)
        # parse_content_document(document)
        if @item.nav?
          content_document.navigations = parse_navigations(document)
        end
        content_document
      end

      # @param [Nokogiri::HTML::Document] document HTML document or element including nav
      # @return [Array<EPUB::ContentDocument::Navigation::Nav>] navs array of Nav object
      def parse_navigations(document)
        document.each_element_by_xpath('/xhtml:html/xhtml:body//xhtml:nav', EPUB::NAMESPACES).collect {|elem| parse_navigation elem}
      end

      # @param [Nokogiri::XML::Element] element nav element
      # @return [EPUB::ContentDocument::Navigation::Nav] nav Nav object
      def parse_navigation(element)
        nav = EPUB::ContentDocument::Navigation::Navigation.new
        nav.text = find_heading(element)
        hidden = element.attribute_with_prefix('hidden')
        nav.hidden = hidden.nil? ? nil : true
        nav.type = element.attribute_with_prefix('type', 'epub')
        element.each_element_by_xpath('./xhtml:ol/xhtml:li', EPUB::NAMESPACES).map do |elem|
          nav.items << parse_navigation_item(elem)
        end

        nav
      end

      # @param [Nokogiri::XML::Element] element li element
      def parse_navigation_item(element)
        item = EPUB::ContentDocument::Navigation::Item.new
        a_or_span = element.each_element_by_xpath('./xhtml:a[1]|xhtml:span[1]', EPUB::NAMESPACES).first
        return a_or_span if a_or_span.nil?

        item.text = a_or_span.content
        if a_or_span.name == 'a'
          if item.text.empty?
            embedded_content = a_or_span.each_element_by_xpath('./xhtml:audio[1]|xhtml:canvas[1]|xhtml:embed[1]|xhtml:iframe[1]|xhtml:img[1]|xhtml:math[1]|xhtml:object[1]|xhtml:svg[1]|xhtml:video[1]', EPUB::NAMESPACES).first
            unless embedded_content.nil?
              case embedded_content.name
              when 'audio', 'canvas', 'embed', 'iframe'
                item.text = embedded_content.attribute_with_prefix('name') || embedded_content.attribute_with_prefix('srcdoc')
              when 'img'
                item.text = embedded_content.attribute_with_prefix('alt')
              when 'math', 'object'
                item.text = embedded_content.attribute_with_prefix('name')
              when 'svg', 'video'
              else
              end
            end
            item.text = a_or_span.attribute_with_prefix('title').to_s if item.text.nil? || item.text.empty?
          end
          item.href = a_or_span.attribute_with_prefix('href')
          item.item = @item.find_item_by_relative_iri(item.href)
        end
        item.items = element.each_element_by_xpath('./xhtml:ol[1]/xhtml:li', EPUB::NAMESPACES).map {|li| parse_navigation_item(li)}

        item
      end

      private

      # @param [Nokogiri::XML::Element] element nav element
      # @return [String] heading heading text
      def find_heading(element)
        heading = element.each_element_by_xpath('./xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6|xhtml:hgroup', EPUB::NAMESPACES).first

        return nil if heading.nil?
        return heading.content unless heading.name == 'hgroup'

        (heading.each_element_by_xpath(".//xhtml:h1", EPUB::NAMESPACES) ||
         heading.each_element_by_xpath(".//xhtml:h2", EPUB::NAMESPACES) ||
         heading.each_element_by_xpath(".//xhtml:h3", EPUB::NAMESPACES) ||
         heading.each_element_by_xpath(".//xhtml:h4", EPUB::NAMESPACES) ||
         heading.each_element_by_xpath(".//xhtml:h5", EPUB::NAMESPACES) ||
         heading.each_element_by_xpath(".//xhtml:h6", EPUB::NAMESPACES)).first.content
      end
    end
  end
end
