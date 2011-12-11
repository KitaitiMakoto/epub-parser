require 'epub/book'
require 'epub/parser/version'
require 'nokogiri'

module EPUB
  class Parser
    def initialize(filepath, working_directory, options = {})
      raise 'File #{filepath} not readable' unless File.readable_real? filepath
      raise 'File #{working_directory} already exists' if File.file? working_directory
        
      @filepath = File.realpath filepath
      Dir.mkdir(working_directory) unless File.directory? working_directory
      @dir = File.realpath working_directory

      @book = Book.new

      unzip_cmd = options['unzip-command'] || 'unzip'
      unzip_cmd << " #{@filepath} -d #{@dir}"
      system unzip_cmd
    end

    def parse
      Dir.chdir @dir do
        parse_ocf
        parse_publication
        # parse_content_codument
        # ...

        @book
      end
    end

    private

    def parse_ocf
      file = File.join @dir, OCF::DIRECTORY, OCF::Container::FILE
      doc = Nokogiri.XML open(file)

      container = OCF::Container.new
      doc.xpath('/xmlns:container/xmlns:rootfiles/xmlns:rootfile', doc.namespaces).each do |elem|
        rootfile = OCF::Container::Rootfile.new
        %w[full-path media-type].each do |attr|
          rootfile.send(attr.gsub(/-/, '_') + '=', elem[attr])
          container.rootfiles << rootfile
        end
      end

      @book.container = container
    end

    def parse_publication
      file = File.join @dir, @book.rootfile
      doc = Nokogiri.XML open(file)

      package = Publication::Package.new
      elem = doc.xpath('/xmlns:package', doc.namespaces)[0]
      %w[version unique_identifier prefix lang dir id].each do |attr|
        package.send(attr.gsub(/-/, '_') + '=', elem[attr])
      end

      metadata = Publication::Package::Metadata.new
      elem = elem.xpath('./xmlns:metadata')[0]
p elem

      @book.package = package
    end
  end
end
