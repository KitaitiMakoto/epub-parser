require 'epub/book'
require 'epub/parser/version'

module EPUB
  class Parser
    def initialize(filepath, working_directory, options = {})
      raise 'File #{filepath} not readable' unless File.readable_real? filepath
      raise 'File #{working_directory} already exists' if File.file? working_directory
        
      @filepath = filepath
      Dir.mkdir(working_directory) unless File.directory? working_directory
      @dir = working_directory

      @book = Book.new

      unzip_cmd = options[:unzip] || 'unzip'
      unzip_cmd << " #{@filepath} -d #{@dir}"
      system unzip_cmd
    end

    def parse
      parse_publication
      parse_content_codument
      # ...
    end

    def parse_publication
    end
  end
end
