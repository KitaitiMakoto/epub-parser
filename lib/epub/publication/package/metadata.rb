module EPUB
  module Publication
    class Package
      class Metadata
        elems = [:identifiers, :titles, :languages] +
                [:contributors, :coverages, :creators, :dates, :descriptions, :formats, :publishers,
                 :relations, :rights, :sources, :subjects, :types]
        attr_accessor *(elems.collect {|elem| "dc_#{elem}"})
        elems.each do |elem|
          alias_method elem, "dc_#{elem}"
          alias_method "#{elem}=", "dc_#{elem}="
        end
        attr_accessor :links

        class Identifier
          attr_accessor :content, :id
        end

        class Title
          attr_accessor :content, :id, :lang, :dir
        end

        class DCMES
          attr_accessor :content, :id, :lang, :dir
        end
      end
    end
  end
end
