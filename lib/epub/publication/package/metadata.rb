require 'yaml'
require 'json'

module EPUB
  module Publication
    class Package
      class Metadata
        ELEMS = [:identifiers, :titles, :languages] +
                [:contributors, :coverages, :creators, :dates, :descriptions, :formats, :publishers,
                 :relations, :rights, :sources, :subjects, :types]
        attr_accessor :package, :unique_identifier,
                      *(ELEMS.collect {|elem| "dc_#{elem}"})
        ELEMS.each do |elem|
          alias_method elem, "dc_#{elem}"
          alias_method "#{elem}=", "dc_#{elem}="
        end
        attr_accessor :links

        def to_hash
          ELEMS.inject({}) do |hsh, elem|
            hsh[elem] = __send__(elem)
            hsh
          end
        end

        def to_line
          data = to_hash
          key_width = data.keys.map {|k| k.length}.max + 3
          to_hash.inject([]) do |lines, (k, v)|
            lines << (k.to_s.capitalize + ':').ljust(key_width) + v.join(', ')
            lines
          end.join("\n")
        end

        def to_json
          to_hash.to_json
        end

        def to_yaml
          to_hash.to_yaml
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
