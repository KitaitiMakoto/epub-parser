module EPUB
  class OCF
    class PhysicalContainer
      class File < self
        def open
          yield self
        end

        def read(path_name)
          ::File.read(::File.join(@container_path, path_name))
        end
      end
    end
  end
end
