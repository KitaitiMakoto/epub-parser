require "zip"

module EPUB
  class OCF
    class PhysicalContainer
      class Rubyzip < self
        def open
          orig_encoding = Zip.force_entry_names_encoding
          begin
            Zip.force_entry_names_encoding = "UTF-8"
            Zip::File.open @container_path do |archive|
              @monitor.synchronize do
                @archive = archive
                begin
                  yield self
                ensure
                  @archive = nil
                end
              end
            end
          ensure
            Zip.force_entry_names_encoding = orig_encoding
          end
        end

        def read(path_name)
          if @archive
            @archive.read(path_name)
          else
            open {|container| container.read(path_name)}
          end
        rescue Errno::ENOENT => error
          raise NoEntry.from_error(error)
        end
      end
    end
  end
end
