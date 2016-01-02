require 'epub/ocf/physical_container/archive_zip'
require 'epub/ocf/physical_container/unpacked_directory'
require 'epub/ocf/physical_container/unpacked_uri'

module EPUB
  class OCF
    # @todo: Make thread save
    class PhysicalContainer
      @adapter = ArchiveZip

      class << self
        def adapter
          raise NoMethodError, "undefined method `#{__method__}' for #{self}" unless self == PhysicalContainer
          @adapter
        end

        def adapter=(adapter)
          raise NoMethodError, "undefined method `#{__method__}' for #{self}" unless self == PhysicalContainer
          @adapter = adapter.instance_of?(Class) ? adapter : const_get(adapter)
          adapter
        end

        def open(container_path)
          _adapter.new(container_path).open do |container|
            yield container
          end
        end

        def read(container_path, path_name)
          open(container_path) {|container|
            container.read(path_name)
          }
        end

        private

        def _adapter
          (self == PhysicalContainer) ? @adapter : self
        end
      end

      def initialize(container_path)
        @container_path = container_path
      end
    end
  end
end
