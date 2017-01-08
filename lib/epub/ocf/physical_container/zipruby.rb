require 'zipruby'

module EPUB
  class OCF
    class PhysicalContainer
      class Zipruby < self
        def open
          Zip::Archive.open @container_path do |archive|
            @monitor.synchronize do
              begin
                @archive = archive
                yield self
              rescue ::Zip::Error => error
                raise NoEntry.from_error(error)
              ensure
                @archive = nil
              end
            end
          end
        end

        def read(path_name)
          if @archive
            @archive.fopen(path_name) {|entry| entry.read}
          else
            open {|container| container.read(path_name)}
          end
        rescue ::Zip::Error => error
          raise NoEntry.from_error(error)
        ensure
          @archive = nil
        end
      end
    end
  end
end
