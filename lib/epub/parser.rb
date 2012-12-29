require 'epub'
require 'epub/constants'
require 'zipruby'
require 'nokogiri'

module EPUB
  class Parser
    class << self
      # @example
      #   EPUB::Parser.parse('path/to/book.epub') # => EPUB::Book object
      # @example
      #   class MyBook
      #     include EPUB
      #   end
      #   book = MyBook.new
      #   EPUB::Parser.parse('path/to/book.epub', :book => book) # => #<MyBook:0x000000019760e8 @epub_file=..> (book itself)
      # @example
      #   EPUB::Parser.parse('path/to/book.epub', :class => MyBook) # => #<MyBook:0x000000019b0568 @epub_file=...> (the instance of MyClass)
      # @param [String] filepath
      # @param [Hash] options the type of return is specified by this argument.
      #   If no options, returns {EPUB::Book} object.
      #   For details of options, see below.
      # @option options [EPUB] :book instance of class which includes {EPUB} module
      # @option options [Class] :class class which includes {EPUB} module
      # @return [EPUB] object which is an instance of class including {EPUB} module.
      #   When option :book passed, returns the same object whose attributes about EPUB are set.
      #   When option :class passed, returns the instance of the class.
      #   Otherwise returns {EPUB::Book} object.
      def parse(filepath, options = {})
        new(filepath, options).parse
      end
    end

    def initialize(filepath, options = {})
      raise "File #{filepath} not readable" unless File.readable_real? filepath

      @filepath = File.realpath filepath
      @book = create_book options
      @book.epub_file = @filepath
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

    module Utils
      # Extract the value of attribute of element
      # 
      # @todo Refinement Nokogiri::XML::Node instead of use this method after Ruby 2.0 becomes popular
      # 
      # @param [Nokogiri::XML::Element] element
      # @param [String] name name of attribute excluding namespace prefix
      # @param [String, nil] prefix XML namespace prefix in {EPUB::Constants::NAMESPACES} keys
      # @return [String] value of attribute when the attribute exists
      # @return nil when the attribute doesn't exist
      def extract_attribute(element, name, prefix=nil)
        attr = element.attribute_with_ns(name, EPUB::NAMESPACES[prefix])
        attr.nil? ? nil : attr.value
      end
      module_function :extract_attribute
    end

    private

    def create_book(params)
      case
      when params[:book]
        params[:book]
      when params[:class]
        params[:class].new
      else
        require 'epub/book'
        Book.new
      end
    end
  end
end

require 'epub/parser/version'
require 'epub/parser/ocf'
require 'epub/parser/publication'
require 'epub/parser/content_document'
