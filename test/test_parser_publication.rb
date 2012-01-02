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

    def test_manifest_has_4_items
      assert_equal 4, @manifest.items.length
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
  end
end
