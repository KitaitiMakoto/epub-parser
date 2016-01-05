require 'archive/zip'

module EPUB
  class OCF
    class PhysicalContainer
      class ArchiveZip < self
        def initialize(container_path)
          super
          @entries = {}
          @last_iterated_entry_index = 0
        end

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
          target_index = @entries[path_name]
          if @archive
            @archive.each.with_index do |entry, index|
              if target_index
                if target_index == index
                  return entry.file_data.read
                else
                  next
                end
              end
              next if index < @last_iterated_entry_index
              # We can force encoding UTF-8 becase EPUB spec allows only UTF-8 filenames
              entry_path = entry.zip_path.force_encoding('UTF-8')
              @entries[entry_path] = index
              @last_iterated_entry_index = index
              if entry_path == path_name
                return entry.file_data.read
              end
            end

            raise NoEntry
          else
            open {|container| container.read(path_name)}
          end
        end
      end
    end
  end
end
