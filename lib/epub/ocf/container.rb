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
      end
    end
  end
end
