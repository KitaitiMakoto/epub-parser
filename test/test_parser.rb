require File.expand_path 'helper', File.dirname(__FILE__)
require 'epub/parser'

class TestParser < Test::Unit::TestCase
  def setup
    @parser = Parser.new
  end

  def test_example
    assert false
  end
end
