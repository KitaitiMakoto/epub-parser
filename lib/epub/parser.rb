require 'epub/constants'
require 'epub/parser/version'
require 'epub/parser/ocf'
require 'epub/parser/publication'
require 'epub/parser/content_document'
require 'zipruby'
require 'nokogiri'

module EPUB
  class Parser
    class << self
      def parse(file, options = {})
        new(file, options).parse
      end
    end

    def initialize(filepath, options = {})
      raise "File #{filepath} not readable" unless File.readable_real? filepath

      @filepath = File.realpath filepath
      @book = create_book options
    end

    def parse
      Zip::Archive.open @filepath do |zip|
        @book.ocf = OCF.parse(zip)
        @book.package = Publication.parse(zip, @book.rootfile_path)
        # @book.content_document =??? parse_content_document
        # ...
      end

      @book
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
