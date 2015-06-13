require 'forwardable'
require 'epub/ocf/physical_container/zipruby'

module EPUB
  class OCF
    class PhysicalContainer
      @adapter = Zipruby

      class << self
        extend Forwardable

        attr_accessor :adapter
        def_delegators :@adapter, :open, :read
      end

      def initialize(container_path)
        @container_path = container_path
      end
    end
  end
end
