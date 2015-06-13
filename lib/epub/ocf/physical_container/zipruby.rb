require 'zipruby'

module EPUB
  class OCF
    class PhysicalContainer
      class Zipruby < self
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
          Zip::Archive.open @container_path do |archive|
            @archive = archive
            result = yield self
            @archive = nil
            result
          end
        end

        def read(path_name)
          if @archive
            @archive.fopen(path_name) {|entry| entry.read}
          else
            Zip::Archive.open(@container_path) {|archive|
              archive.fopen(path_name) {|entry| entry.read}
            }
          end
        end
      end
    end
  end
end
