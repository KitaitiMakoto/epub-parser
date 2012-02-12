require 'json'

module EPUB
  module Publication
    class Package
      class Metadata
        ELEMS = [:identifiers, :titles, :languages] +
                [:contributors, :coverages, :creators, :dates, :descriptions, :formats, :publishers,
                 :relations, :rights, :sources, :subjects, :types]
        attr_accessor :package,
                      *(ELEMS.collect {|elem| "dc_#{elem}"})
        ELEMS.each do |elem|
          alias_method elem, "dc_#{elem}"
          alias_method "#{elem}=", "dc_#{elem}="
        end
        attr_accessor :links

        def to_json(pretty = false)
          obj = {}
          ELEMS.each do |elem|
            obj[elem] = __send__(elem)
          end
          obj.to_json
        end

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
