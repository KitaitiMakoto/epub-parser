require 'open-uri'

module EPUB
  class OCF
    class PhysicalContainer
      class UnpackedURI < self
        # EPUB URI: http://example.net/path/to/book/
        # container.xml: http://example.net/path/to/book/META-INF/container.xml
        # @param [URI, String] container_path URI of EPUB container's root directory.
        #   For exapmle, <code>"http://example.net/path/to/book/"</code>, which
        #   should contain <code>"http://example.net/path/to/book/META-INF/container.xml"</code> as its container.xml file. Note that this should end with "/"(slash).
        def initialize(container_path)
          super(URI(container_path))
        end

        def open
          yield self
        end

        def read(path_name)
          (@container_path + path_name).read
        rescue ::OpenURI::HTTPError => error
          raise NoEntry.from_error(error)
        end
      end
    end
  end
end
