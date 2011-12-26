require 'epub/book'
require 'epub/parser/version'
require 'epub/parser/ocf'
require 'epub/parser/publication'
require 'epub/parser/content_document'
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
      @book.ocf = parse_ocf
      @book.package = parse_publication
      @book.content_document = parse_content_document
      # ...

      @book
    end

    def parse_ocf
      OCF.parse @dir
    end

    def parse_publication
      Publication.parse File.join(@dir, @book.rootfile_path)
    end

    def parse_content_document
      # ContentDocument.parse @dir
    end
  end
end
