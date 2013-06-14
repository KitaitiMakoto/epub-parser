module EPUB
  class OCF
    class Container
      FILE = 'container.xml'

      attr_reader :rootfiles

      def initialize
        @rootfiles = []
      end

      # syntax sugar
      def rootfile
        rootfiles.first
      end

      class Rootfile
        attr_accessor :full_path, :media_type

        # @param full_path [Addressable::URI|nil]
        # @param media_type [String]
        def initialize(full_path=nil, media_type=EPUB::MediaType::ROOTFILE)
          @full_path, @media_type = full_path, media_type
        end
      end
    end
  end
end
