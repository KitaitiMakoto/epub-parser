require 'monitor'
require 'epub/ocf/physical_container/archive_zip'
require 'epub/ocf/physical_container/unpacked_directory'
require 'epub/ocf/physical_container/unpacked_uri'

module EPUB
  class OCF
    # @todo: Make thread save
    class PhysicalContainer
      class NoEntry < StandardError
        class << self
          def from_error(error)
            no_entry = new(error.message)
            no_entry.set_backtrace error.backtrace
            no_entry
          end
        end
      end

      @adapter = ArchiveZip

      class << self
        def find_adapter(adapter)
          return adapter if adapter.instance_of? Class
          if adapter == :Zipruby && ! const_defined?(adapter)
            require 'epub/ocf/physical_container/zipruby'
          end
          const_get adapter
        end

        def adapter
          raise NoMethodError, "undefined method `#{__method__}' for #{self}" unless self == PhysicalContainer
          @adapter
        end

        def adapter=(adapter)
          raise NoMethodError, "undefined method `#{__method__}' for #{self}" unless self == PhysicalContainer
          @adapter = find_adapter(adapter)
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
        @monitor = Monitor.new
      end
    end
  end
end
