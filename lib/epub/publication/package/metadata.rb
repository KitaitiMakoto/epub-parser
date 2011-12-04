module EPUB
  module Publication
    class Package
      class Metadata
        elems = [:identifiers, :titles, :languages] +
                [:contributers, :coverages, :creators, :dates, :descriptions, :formats, :publishers,
                 :relations, :rigths, :sources, :subjects, :types]
        attr_accessor *(elems.collect {|elem| "dc_#{elem}"})
        elems.each do |elem|
          alias_method elem, "dc_#{elem}"
          alias_method "#{elem}=", "dc_#{elem}="
        end
        attr_accessor :metas, :links
      end
    end
  end
end
