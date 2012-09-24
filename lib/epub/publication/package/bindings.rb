module EPUB
  module Publication
    class Package
      class Bindings
        attr_accessor :package,
                      :media_types

        def [](media_type)
          index = @media_types.index {|mt| mt.media_type == media_type}
          return index unless index
          @media_types[index]
        end

        def <<(media_type)
          @media_types ||= []
          @media_types << media_type
        end

        class MediaType
          attr_accessor :media_type, :handler
        end
      end
    end
  end
end
