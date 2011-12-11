require File.expand_path 'helper', File.dirname(__FILE__)
require 'epub/parser'

class TestParser < Test::Unit::TestCase
  def setup
    @parser = Parser.new File.join(File.dirname(__FILE__), '../samples/EPUBGUIDE.epub'), 'samples/tmp'
  end

  def test_parse_publication
    book = @parser.parse
    p book.package
  end
end
