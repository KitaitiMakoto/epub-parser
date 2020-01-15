require "set"

module EPUB
  module ContentDocument
    class Navigation < XHTML
      attr_accessor :navigations

      def initialize
        @navigations = []
        @hidden = false
        @parent = nil
        super
      end

      def toc
        navigations.find(&:toc?)
      end

      def page_list
        navigations.find(&:page_list?)
      end

      def landmarks
        navigations.find(&:landmarks?)
      end

      # Enumerator version of toc
      def contents
        enum_for(:each_content).to_a
      end

      # Enumerator version of page_list
      #  Usage: navigation.enum_for(:pages)
      def pages
        raise NotImplementedError
      end

      # @todo Enumerator version of landmarks

      # iterator for #toc
      def each_content
        toc.traverse do |content, _|
          yield content
        end
      end

      # iterator for #page_list
      def each_page
        raise NotImplementedError
      end

      # iterator for #landmark
      def each_landmark
        raise NotImplementedError
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

      # @todo handle with epub:type such as bodymatter
      class Item
        include Hidable

        attr_accessor :items, :text,
                      :content_document, :item
        attr_reader :href, :types

        def initialize
          @items = ItemList.new
          @items.parent = self
          @types = Set.new
        end

        def href=(iri)
          @href = iri.kind_of?(Addressable::URI) ? iri : Addressable::URI.parse(iri)
        end

        def traverse(depth=0, &block)
          block.call self, depth
          items.each do |item|
            item.traverse depth + 1, &block
          end
        end

        def types=(ts)
          @types = ts.kind_of?(Set) ? ts : Set.new(ts)
        end

        # For backward compatibility
        def type
          @types.find {|t|
            %w[toc page_list landmarks].include? t
          }
        end

        # For backward compatibility
        def type=(t)
          @types << t
        end

        %w[toc page_list landmarks].each do |type|
          define_method "#{type}?" do
            @types.include? type
          end
        end
      end

      # @todo Implement method to represent navigation structure
      class Navigation < Item
        module Type
          TOC       = 'toc'
          PAGE_LIST = 'page_list'
          LANDMARKS = 'landmarks'
        end

        alias navigations items
        alias navigations= items=
        alias heading text
        alias heading= text=
      end

      class ItemList < Array
        include Hidable

        def <<(item)
          super
          item.parent = self
        end
      end
    end
  end
end
