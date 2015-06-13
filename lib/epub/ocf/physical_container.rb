require 'epub/ocf/physical_container/zipruby'

module EPUB
  class OCF
    class PhysicalContainer
      def initialize(container_path)
        @container_path = container_path
      end
    end
  end
end
