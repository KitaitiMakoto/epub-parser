module EPUB
  module Publication
    class Package
      class Spine
        attr_accessor :id, :toc, :page_progression_direction
                      :itemrefs

        def <<(itemref)
          @itemrefs ||= []
          @itemrefs << itemref
        end

        class Itemref
          attr_accessor :idref, :linear, :id, :properties
        end
      end
    end
  end
end
