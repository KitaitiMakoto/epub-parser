module EPUB
  module Publication
    class Package
      class Spine
        attr_accessor :package,
                      :id, :toc, :page_progression_direction
        attr_reader :itemrefs

        def <<(itemref)
          @itemrefs ||= []
          itemref.spine = self
          @itemrefs << itemref
        end

        # Returns a list of Manifest::Item
        def items
          raise 'Not implemented yet'
        end

        class Itemref
          attr_accessor :spine,
                        :idref, :linear, :id, :properties

          def item
            @spine.package.manifest[idref]
          end
        end
      end
    end
  end
end
