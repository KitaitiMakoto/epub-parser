module EPUB
  module ContentDocument
    class Navigation
      attr_accessor :navs
      alias navigations navs
      alias navigations= navs=

      def toc
        navs.selector {|nav| nav.type == Type::TOC}.first
      end

      def page_list
        navs.selector {|nav| nav.type == Type::PAGE_LIST}.first
      end

      def landmarks
        navs.selector {|nav| nav.type == Type::LANDMARKS}.first
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
    end
  end
end
