module EPUB
  module Publication
    class Package
      class Metadata
        elems = [:identifiers, :titles, :languages] +
                [:contributors, :coverages, :creators, :dates, :descriptions, :formats, :publishers,
                 :relations, :rights, :sources, :subjects, :types]
        attr_accessor :package,
                      *(elems.collect {|elem| "dc_#{elem}"})
        elems.each do |elem|
          alias_method elem, "dc_#{elem}"
          alias_method "#{elem}=", "dc_#{elem}="
        end
        attr_accessor :links

        class Identifier
          attr_accessor :content, :id

          def to_s
            content
          end
        end

        class Title
          attr_accessor :content, :id, :lang, :dir

          def to_s
            content
          end
        end

        class DCMES
          attr_accessor :content, :id, :lang, :dir

          def to_s
            content
          end
        end
      end
    end
  end
end
