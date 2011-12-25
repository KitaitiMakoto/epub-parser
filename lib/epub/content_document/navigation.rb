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

      class Nav
        attr_accessor :heading, :ol,
                      :items, # children of ol, thus li
                      :type, # toc, page-list, landmarks or other
                      :hidden

        # #show method and #hide are unneccessary
        # because this is for parser, not for builder nor manipulator
        def hidden?
        end

        class Ol
          # list-style :none
          attr_accessor :hidden

          def hidden?
          end

          # may be followed by ol or be a leaf node
          class A
            attr_accessor :ol, # optional
                          :hidden

            def hidden?
            end
          end

          # must be followed by ol, or must not be a leaf node
          class Span
            attr_accessor :ol, # required
                          :hidden
            def hidden?
            end
          end
        end
      end
    end
  end
end
