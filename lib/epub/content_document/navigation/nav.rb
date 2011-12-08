module EPUB
  module ContentDocument
    class Navigation
      class Nav
        attr_accessor :heading, :ol,
        :items, # children of ol, thus li
        :type, # toc, page-list, landmarks or other
        :hidden

        # Unneccessary #show and #hide methods
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
