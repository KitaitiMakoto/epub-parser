require 'epub'
require 'epub/constants'
require 'epub/book'

module EPUB
  class Parser
    class << self
      # Parse an EPUB file
      # 
      # @example
      #   EPUB::Parser.parse('path/to/book.epub') # => EPUB::Book object
      # 
      # @example
      #   class MyBook
      #     include EPUB
      #   end
      #   book = MyBook.new
      #   parsed_book = EPUB::Parser.parse('path/to/book.epub', :book => book) # => #<MyBook:0x000000019760e8 @epub_file=..>
      #   parsed_book.equal? book # => true
      # 
      # @example
      #   book = EPUB::Parser.parse('path/to/book.epub', :class => MyBook) # => #<MyBook:0x000000019b0568 @epub_file=...>
      #   book.instance_of? MyBook # => true
      # 
      # @param [String] filepath
      # @param [Hash] options the type of return is specified by this argument.
      #   If no options, returns {EPUB::Book} object.
      #   For details of options, see below.
      # @option options [EPUB] :book instance of class which includes {EPUB} module
      # @option options [Class] :class class which includes {EPUB} module
      # @option options [EPUB::OCF::PhysicalContainer, Symbol] :container_adapter OCF physical container adapter to use when parsing EPUB container
      #   When class passed, it is used. When symbol passed, it is considered as subclass name of {EPUB::OCF::PhysicalContainer}.
      #   If omitted, {EPUB::OCF::PhysicalContainer.adapter} is used.
      # @return [EPUB] object which is an instance of class including {EPUB} module.
      #   When option :book passed, returns the same object whose attributes about EPUB are set.
      #   When option :class passed, returns the instance of the class.
      #   Otherwise returns {EPUB::Book} object.
      def parse(filepath, **options)
        new(filepath, options).parse
      end
    end

    def initialize(filepath, **options)
      path_is_uri = (options[:container_adapter] == EPUB::OCF::PhysicalContainer::UnpackedURI or
                     options[:container_adapter] == :UnpackedURI or
                     EPUB::OCF::PhysicalContainer.adapter == EPUB::OCF::PhysicalContainer::UnpackedURI)

      raise "File #{filepath} not found" if
        !path_is_uri and !File.exist?(filepath)

      @filepath = path_is_uri ? filepath : File.realpath(filepath)
      @book = create_book(options)
      if path_is_uri
        @book.container_adapter = :UnpackedURI
      elsif File.directory? @filepath
        @book.container_adapter = :UnpackedDirectory
      end
      @book.epub_file = @filepath
      if options[:container_adapter]
        @book.container_adapter = options[:container_adapter]
      end
    end

    def parse
      @book.container_adapter.open @filepath do |container|
        @book.ocf = OCF.parse(container)
        @book.ocf.container.rootfiles.each {|rootfile|
          package = Publication.parse(container, rootfile.full_path.to_s)
          rootfile.package = package
          @book.packages << package
          package.book = @book
        }
      end

      @book
    end

    private

    def create_book(params)
      case
      when params[:book]
        params[:book]
      when params[:class]
        if params[:initialize_with]
          params[:class].new params[:initialize_with]
        else
          params[:class].new
        end
      else
        Book.new
      end
    end
  end
end

require 'epub/parser/version'
require 'epub/parser/xml_document'
require 'epub/parser/ocf'
require 'epub/parser/publication'
require 'epub/parser/content_document'
