# -*- coding: utf-8 -*-
require File.expand_path 'helper', File.dirname(__FILE__)
require 'epub/parser/publication'

class TestParserPublication < Test::Unit::TestCase
  def setup
    @parser = Parser::Publication.new 'test/fixtures/book/OPS/ルートファイル.opf'
  end

  class TestParseManifest < TestParserPublication
    def setup
      super
      @manifest = @parser.parse_manifest
    end

    def test_manifest_has_5_items
      assert_equal 5, @manifest.items.length
    end

    def test_item_has_full_path_as_iri_attribute
      actual = File.expand_path 'fixtures/book/OPS/nav.xhtml', File.dirname(__FILE__)

      assert_equal actual, @manifest['nav'].iri.to_s
    end

    def test_fallback_attribute_of_item_should_be_item_object
      fallback = @manifest['manifest-item-2'].fallback

      assert_instance_of Publication::Package::Manifest::Item, fallback
      assert_equal 'manifest-item-fallback', fallback.id
    end

    def test_item_is_readable
      item = @manifest.items.first
      doc = Nokogiri.XML item.read

      assert_equal 'html', doc.root.name
    end
  end

  class TestParseGuide < TestParserPublication
    def setup
      super
      @guide = @parser.parse_guide
    end

    def test_guide_has_one_reference
      assert_equal 1, @guide.references.length
    end

    def test_guide_has_cover_reference
      assert @guide.cover
      assert_equal 'cover', @guide.cover.type
    end

    def test_reference_refers_item
      @parser.parse_manifest

      assert_instance_of EPUB::Publication::Package::Manifest::Item, @guide.cover.item
    end
  end
end
