require 'zipruby'

if $VERBOSE
  warn <<EOW
[WARNING]Default OCF physical container adapter will become ArchiveZip, which uses archive-zip gem to extract contents from EPUB package, instead of current default Zipruby, which uses zipruby gem, in the near future.
You can try ArchiveZip adapter by:

1. gem install archive-zip
2. require 'epub/ocf/physical_container/archive_zip'
3. EPUB::OCF::PhysicalContainer.adapter = :ArchiveZip

If you find problems, please inform me via GitHub issues: https://github.com/KitaitiMakoto/epub-parser/issues
EOW
end

module EPUB
  class OCF
    class PhysicalContainer
      class Zipruby < self
        def open
          Zip::Archive.open @container_path do |archive|
            begin
              @archive = archive
              yield self
            ensure
              @archive = nil
            end
          end
        end

        def read(path_name)
          if @archive
            @archive.fopen(path_name) {|entry| entry.read}
          else
            open {|container| container.read(path_name)}
          end
        end
      end
    end
  end
end
