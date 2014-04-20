module EPUB
  module ContentDocument
    class Navigation < XHTML
      attr_accessor :navigations

      def initialize
        @navigations = []
        super
      end

      def toc
        navigations.selector {|nav| nav.type == Navigation::Type::TOC}.first
      end

      def page_list
        navigations.selector {|nav| nav.type == Nagivation::Type::PAGE_LIST}.first
      end

      def landmarks
        navigations.selector {|nav| nav.type == Navigation::Type::LANDMARKS}.first
      end

      # Enumerator version of toc
      #  Usage: nagivation.enum_for(:contents)
      def contents
      end

      # Enumerator version of page_list
      #  Usage: navigation.enum_for(:pages)
      def pages
      end

      # iterator for #toc
      def each_content
      end

      # iterator for #page_list
      def each_page
      end

      # iterator for #landmark
      def each_landmark
      end

      def navigation
        navigations.first
      end

      module Hidable
        attr_accessor :hidden, :parent

        def hidden?
          if @hidden.nil?
            @parent ? @parent.hidden? : false
          else
            true
          end
        end
      end

      class Item
        include Hidable

        attr_accessor :items, :text,
                      :content_document, :href, :item

        def initialize
          @items = ItemList.new
          @items.parent = self
        end

        def traverse(depth=0, &block)
          block.call self, depth
          items.each do |item|
            item.traverse depth + 1, &block
          end
        end
      end

      class Navigation < Item
        module Type
          TOC       = 'toc'
          PAGE_LIST = 'page_list'
          LANDMARKS = 'landmarks'
        end

        attr_accessor :type
        alias navigations items
        alias navigations= items=
        alias heading text
        alias heading= text=
      end

      class ItemList < Array
        include Hidable
      end
    end
  end
end
