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
          raise NoEntry.from_error(error)
        end
      end
    end
  end
end
