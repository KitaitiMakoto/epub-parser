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

        # @yield [itemref]
        # @yieldparam [Itemref] itemref
        # @yieldreturn [Object] returns the last value of block
        # @return [Object, Enumerator]
        #   returns the last value of block when block given, Enumerator when not
        def each_itemref
          if block_given?
            itemrefs.each {|itemref| yield itemref}
          else
            enum_for :each_itemref
          end
        end

        # @return [Enumerator] Enumerator which yeilds {Manifest::Item}
        #   referred by each of {#itemrefs}
        def items
          itemrefs.collector {|itemref| itemref.item}
        end

        class Itemref
          attr_accessor :spine,
                        :idref, :linear, :id, :properties

          # @return [Package::Manifest::Item] item referred by this object
          def item
            @item ||= @spine.package.manifest[idref]
          end
        end
      end
    end
  end
end
