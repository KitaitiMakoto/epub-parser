require File.expand_path '../../helper', File.dirname(__FILE__)
require 'epub/publication/package/guide'

include Publication

class TestGuide < Test::Unit::TestCase
  def setup
    @spine = Package::Guide.new
  end

  def test_example
    assert false
  end
end
