require 'archive/zip'

module EPUB
  class OCF
    class PhysicalContainer
      class ArchiveZip < self
        def open
          Archive::Zip.open @container_path do |archive|
            @archive = archive
            begin
              yield self
            ensure
              @archive = nil
            end
          end
        end

        def read(path_name)
          if @archive
            @archive.each do |entry|
              # We can force encoding UTF-8 becase EPUB spec allows only UTF-8 filenames
              if entry.zip_path.force_encoding('UTF-8') == path_name
                return entry.file_data.read
              end
            end
          else
            open {|container| container.read(path_name)}
          end
        end
      end
    end
  end
end
