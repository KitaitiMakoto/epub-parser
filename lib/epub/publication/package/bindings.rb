module EPUB
  module Publication
    class Package
      class Bindings
        attr_accessor :package

        def <<(media_type)
          @media_types ||= {}
          @media_types[media_type.media_type] = media_type
        end

        def [](media_type)
          key, mt = @media_types.detect {|key, _| key == media_type}
          mt
        end

        def media_types
          @media_types.collect {|_, media_type| media_type}
        end

        class MediaType
          attr_accessor :media_type, :handler
        end
      end
    end
  end
end
