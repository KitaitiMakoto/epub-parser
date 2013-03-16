require_relative 'helper'
require 'epub/publication'

class TestPublication < Test::Unit::TestCase
  def test_package_clear_package_attribute_of_submodules_when_attribute_writer_called
    metadata = EPUB::Publication::Package::Metadata.new
    another_metadata = EPUB::Publication::Package::Metadata.new
    package = EPUB::Publication::Package.new

    package.metadata = metadata
    assert_equal metadata.package, package

    package.metadata = another_metadata
    assert_nil metadata.package
  end

  class TestMetadata < TestPublication
    def test_meta_refines_setter_connect_refinee_to_the_meta
      refiner = EPUB::Publication::Package::Metadata::Meta.new
      refinee = EPUB::Publication::Package::Metadata::Meta.new
      refiner.refines = refinee
      assert_same refinee.refiners.first, refiner 
    end

    def test_link_refines_setter_connect_refinee_to_the_link
      refiner = EPUB::Publication::Package::Metadata::Link.new
      refinee = EPUB::Publication::Package::Metadata::Meta.new
      refiner.refines = refinee
      assert_same refinee.refiners.first, refiner 
    end
  end

  class TestManifest < TestPublication
    class TestItem < TestManifest
      def test_content_document_returns_nil_when_not_xhtml_nor_svg
        item = EPUB::Publication::Package::Manifest::Item.new
        item.media_type = 'some/media'
        assert_nil item.content_document
      end

      def test_content_document_returns_navigation_document_when_nav
        item = EPUB::Publication::Package::Manifest::Item.new
        item.media_type = 'application/xhtml+xml'
        item.properties = %w[nav]
        stub(item).read {File.read(File.expand_path('../fixtures/book/OPS/nav.xhtml', __FILE__))}
        stub(item).manifest.stub!.items {[]}

        assert_instance_of EPUB::ContentDocument::Navigation, item.content_document
      end
    end
  end
end
