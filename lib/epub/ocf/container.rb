module EPUB
  class OCF
    class Container
      FILE = 'container.xml'

      attr_accessor :rootfiles

      def initialize
        @rootfiles = []
      end

      # syntax sugar
      def rootfile
        rootfiles[0]
      end

      class Rootfile
        attr_accessor :full_path, :media_type
      end
    end
  end
end
