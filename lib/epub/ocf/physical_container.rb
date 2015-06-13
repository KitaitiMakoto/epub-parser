require 'epub/ocf/physical_container/zipruby'

module EPUB
  class OCF
    class PhysicalContainer
      @adapter = Zipruby

      class << self
        def adapter
          if self == PhysicalContainer
            @adapter
          else
            raise NoMethodError.new("undefined method `#{__method__}' for #{self}")
          end
        end

        def adapter=(adapter)
          if self == PhysicalContainer
            @adapter = adapter
          else
            raise NoMethodError.new("undefined method `#{__method__}' for #{self}")

          end
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
