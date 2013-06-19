require 'enumerabler'

module EPUB
  module Publication
    class Package
      class Guide
        include Inspector::PublicationModel
        attr_accessor :package

        def references
          @references ||= []
        end

        def <<(reference)
          reference.guide = self
          references << reference
        end

        %w[cover title-page toc index glossary acknowledgements bibliography colophon copyright-page dedication epigraph foreword loi lot notes preface text].each do |type|
          method_name = type.gsub('-', '_')
          define_method method_name do
            var = instance_variable_get "@#{method_name}"
            return var if var

            var = references.selector {|ref| ref.type == type}.first
            instance_variable_set "@#{method_name}", var
          end
        end

        class Reference
          attr_accessor :guide,
                        :type, :title, :href

          def item
            return @item if @item

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
