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
                        :type, :title, :href

          def item
            return @item if @item

            len = href.fragment.nil? ? 1 : href.fragment.length + 2
            request_uri = href.request_uri
            @item = @guide.package.manifest.items.selector do |item|
              item.href.request_uri == request_uri
            end.first
          end
        end
      end
    end
  end
end
