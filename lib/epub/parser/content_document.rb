require 'epub/content_document'
require 'epub/constants'
require 'nokogiri'

module EPUB
  class Parser
    class ContentDocument
      include Utils

      class << self
        # @param [EPUB::Publication::Package::Manifest] manifest
        def parse(manifest)
          new(manifest).parse
        end
      end

      attr_reader :manifest

      # @param [EPUB::Publication::Package::Manifest] manifest
      def initialize(manifest)
        @manifest = manifest
      end

      def parse
        raise 'Not implemented yet'
      end

      # @param [Nokogiri::HTML::Document] document HTML document or element including nav
      # @return [Array<EPUB::ContentDocument::Navigation::Nav>] navs array of Nav object
      def parse_navigations(document)
        document.search('/xhtml:html/xhtml:body//xhtml:nav', EPUB::NAMESPACES).collect {|elem| parse_navigation elem}
      end

      # @param [Nokogiri::XML::Element] element nav element
      # @return [EPUB::ContentDocument::Navigation::Nav] nav Nav object
      def parse_navigation(element)
        nav = EPUB::ContentDocument::Navigation::Navigation.new
        nav.text = find_heading(element)
        nav.type = extract_attribute(element, 'type', 'epub')
        nav.items = element.xpath('./xhtml:ol/xhtml:li', EPUB::NAMESPACES).map {|elem| parse_navigation_item(elem)}

        nav
      end

      # @param [Nokogiri::XML::Element] element li element
      def parse_navigation_item(element)
        item = EPUB::ContentDocument::Navigation::Item.new
        a_or_span = element.xpath('./xhtml:a[1]|xhtml:span[1]', EPUB::NAMESPACES).first
        return a_or_span if a_or_span.nil?

        item.text = a_or_span.text
        if a_or_span.name == 'a'
          if item.text.empty?
            embedded_content = a_or_span.xpath('./xhtml:audio[1]|xhtml:canvas[1]|xhtml:embed[1]|xhtml:iframe[1]|xhtml:img[1]|xhtml:math[1]|xhtml:object[1]|xhtml:svg[1]|xhtml:video[1]', EPUB::NAMESPACES).first
            unless embedded_content.nil?
              case embedded_content.name
              when 'audio'
              when 'canvas'
              when 'embed'
              when 'iframe'
                item.text = (extract_attribute(embedded_content, 'name') || extract_attribute(embedded_content, 'srcdoc')).to_s
              when 'img'
                item.text = extract_attribute(embedded_content, 'alt').to_s
              when 'math'
              when 'object'
                item.text = extract_attribute(embedded_content, 'name').to_s
              when 'svg'
              when 'video'
              else
              end
            end
            item.text = extract_attribute(a_or_span, 'title').to_s if item.text.nil? || item.text.empty?
          end
          item.href = Addressable::URI.parse(extract_attribute(a_or_span, 'href'))
          item.item = manifest.items.selector {|it| it.href.request_uri == item.href.request_uri}.first
        end
        item.items = element.xpath('./xhtml:ol[1]/xhtml:li', EPUB::NAMESPACES).map {|li| parse_navigation_item(li)}

        item
      end

      private

      # @param [Nokogiri::XML::Element] element nav element
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
