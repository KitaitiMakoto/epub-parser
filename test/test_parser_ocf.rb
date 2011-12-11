require File.expand_path 'helper', File.dirname(__FILE__)
require 'epub/parser/ocf'

class TestParser < Test::Unit::TestCase
  def setup
    @parser = Parser::OCF.new
  end

  def test_parse_container
    container = @parser.parse_container

    p container

    pend
  end
end

