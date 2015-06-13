require 'zipruby'

module EPUB
  class OCF
    class PhysicalContainer
      class Zipruby < self
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
