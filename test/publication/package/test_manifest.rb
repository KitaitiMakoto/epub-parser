require File.expand_path '../../helper', File.dirname(__FILE__)
require 'epub/publication/package/manifest'

include Publication

class TestManifest < Test::Unit::TestCase
  def setup
    @manifest = Package::Manifest.new
    @item = Package::Manifest::Item.new
  end

  def test_nav_returns_item_with_nav
    @nav = Package::Manifest::Item.new
    @nav.properties = ['nav']
    @manifest << @nav

    assert_equal @nav, @manifest.nav
  end
end
