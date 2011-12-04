require File.expand_path '../../helper', File.dirname(__FILE__)
require 'epub/publication/package/spine'

include Publication

class TestSpine < Test::Unit::TestCase
  def setup
    @spine = Package::Spine.new
    @itemref1 = Package::Spine::Itemref.new
  end

  def test_example
    assert false
  end
end
