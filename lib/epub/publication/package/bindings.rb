module EPUB
  module Publication
    class Package
      class Bindings
        attr_accessor :media_types

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
