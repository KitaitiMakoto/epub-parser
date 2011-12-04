require File.expand_path '../../helper', File.dirname(__FILE__)
require 'epub/publication/package/manifest'

include Publication

class TestManifest < Test::Unit::TestCase
  def setup
    @manifest = Package::Manifest.new
    @item1 = Package::Manifest::Item.new
  end

  def test_example
    assert false
  end
end
