module EPUB
  class OCF
    class PhysicalContainer
      class File < self
        class << self
          def open(container_path)
            new(container_path).open do |container|
              yield container
            end
          end

          def read(container_path, path_name)
            open(container_path) {|container|
              container.read(path_name)
            }
          end
        end

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
