module EPUB
  class OCF
    class PhysicalContainer
      class UnpackedDirectory < self
        def open
          yield self
        end

        def read(path_name)
          ::File.read(::File.join(@container_path, path_name))
        rescue ::Errno::ENOENT => error
          no_entry = NoEntry.new(error.message)
          no_entry.set_backtrace error.backtrace
          raise no_entry
        end
      end
    end
  end
end
