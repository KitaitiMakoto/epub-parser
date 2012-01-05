require 'epub/constants'
require 'epub/parser/version'
require 'epub/parser/ocf'
require 'epub/parser/publication'
require 'epub/parser/content_document'
require 'shellwords'
require 'nokogiri'

module EPUB
  class Parser
    class << self
      def parse(file, dir, options = {})
        new(file, dir, options).parse
      end
    end

    def initialize(filepath, root_directory, options = {})
      raise "File #{filepath} not readable" unless File.readable_real? filepath
      raise "File #{root_directory} already exists" if File.file? root_directory
        
      @filepath = File.realpath filepath
      Dir.mkdir(root_directory) unless File.directory? root_directory
      @dir = File.realpath root_directory

      @book = create_book options

      unzip_cmd = options['unzip-command'] || 'unzip'
      unzip_cmd << " #{@filepath.to_s.shellescape} -d #{@dir.to_s.shellescape}"
      system unzip_cmd
puts unzip_cmd
    end

    def parse
      @book.ocf = parse_ocf
      @book.package = parse_publication
      # @book.content_document =??? parse_content_document
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

    private

    def create_book(params)
      case
      when params[:book]
        options[:book]
      when params[:class]
        options[:class].new
      else
        require 'epub/book'
        Book.new
      end
    end
  end
end
