require 'epub/book'
require 'epub/parser/version'
require 'epub/parser/ocf'
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

    def parse_ocf
      @book.ocf = Parser::OCF.parse @dir
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
