require_relative 'helper'

class TestContentDocument < Test::Unit::TestCase
  include EPUB::ContentDocument

  def test_top_level?
    manifest = EPUB::Publication::Package::Manifest.new
    spine = EPUB::Publication::Package::Spine.new

    item1 = EPUB::Publication::Package::Manifest::Item.new
    item1.id = 'item1'
    item2 = EPUB::Publication::Package::Manifest::Item.new
    item2.id = 'item2'
    manifest << item1 << item2

    itemref = EPUB::Publication::Package::Spine::Itemref.new
    itemref.idref = 'item1'
    spine << itemref

    package = EPUB::Publication::Package.new
    package.manifest = manifest
    package.spine = spine

    doc = XHTML.new
    doc.item = item1
    assert_true doc.top_level?

    doc = XHTML.new
    doc.item = item2
    assert_false doc.top_level?
  end
end
