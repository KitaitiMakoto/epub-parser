require 'enumerabler'

module EPUB
  module Publication
    class Package
      class Guide
        attr_accessor :package

        def references
          @references ||= []
        end

        def <<(reference)
          reference.guide = self
          references << reference
        end

        # Should use epub:type list?
        %w[cover title-page toc index glossary acknowledgements bibliography colophon copyright-page dedication epigraph foreword loi lot notes preface text].each do |type|
          define_method type do
            var = instance_variable_get "@#{type}"
            return var if var

            var = references.selector {|ref| ref.type == type.to_s}.first
            instance_variable_set "@#{type}", var
          end
        end

        class Reference
          attr_accessor :guide,
                        :type, :title, :href,
                        :iri

          def item
            return @item if @item

            len = iri.fragment.nil? ? 1 : iri.fragment.length + 2
            @item = @guide.package.manifest.items.selector do |item|
              item.href == href[0 .. -len]
            end.first
          end
        end
      end
    end
  end
end
