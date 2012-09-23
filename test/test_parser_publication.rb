# -*- coding: utf-8 -*-
require File.expand_path 'helper', File.dirname(__FILE__)
require 'epub/parser/publication'

class TestParserPublication < Test::Unit::TestCase
  def setup
    file = 'test/fixtures/book.epub'
    rootfile = 'OPS/ルートファイル.opf'
    @zip = Zip::Archive.open(file)
    opf = @zip.fopen(rootfile).read
    @parser = EPUB::Parser::Publication.new(opf, rootfile)
    @package = @parser.parse_package
  end

  def teardown
    @zip.close
  end

  def test_parse_package
    assert_equal '3.0', @package.version
  end

  class TestParseMetadata < TestParserPublication
    def setup
      super
      @metadata = @parser.parse_metadata
    end

    def test_has_identifier
      assert_equal 'da265185-8da8-462d-a146-17dd388f61fc', @metadata.identifiers.first.content
    end

    def test_has_unique_identifier
      assert_equal 'da265185-8da8-462d-a146-17dd388f61fc', @metadata.unique_identifier.to_s
    end

    def test_has_five_titles
      assert_equal 5, @metadata.titles.length
    end
  end

  class TestParseManifest < TestParserPublication
    def setup
      super
      @manifest = @parser.parse_manifest
    end

    def test_manifest_has_10_items
      assert_equal 10, @manifest.items.length
    end

    def test_item_has_relative_path_as_iri_attribute
      assert_equal 'OPS/nav.xhtml', @manifest['nav'].iri.to_s
    end

    def test_fallback_attribute_of_item_should_be_item_object
      fallback = @manifest['manifest-item-2'].fallback

      assert_instance_of EPUB::Publication::Package::Manifest::Item, fallback
      assert_equal 'manifest-item-fallback', fallback.id
    end

    def test_item_is_readable
      book = Object.new
      mock(@package).book {book}
      mock(book).epub_file {'test/fixtures/book.epub'}

      item = @manifest.items.first
      doc = Nokogiri.XML item.read

      assert_equal 'html', doc.root.name
    end

    def test_item_can_traverse_fallback_chain
      assert_equal [@manifest['manifest-item-2'], @manifest['manifest-item-fallback'], @manifest['manifest-item-fallback2']],
                   @manifest['manifest-item-2'].fallback_chain
    end

    def test_item_always_has_fallback_chain_including_itself
      item = @manifest['manifest-item-1']

      assert_equal [item], item.fallback_chain
    end

    def test_item_can_use_fallback_chain_when_not_core_media_type_by_default
      item = @manifest['manifest-item-2']
      fallback = item.fallback
      result = item.use_fallback_chain do |current|
        current
      end

      assert_equal fallback, result
    end

    def test_item_can_custome_supported_media_type_in_use_fallback_chain
      item = @manifest['manifest-item-2']
      result = item.use_fallback_chain supported: 'application/pdf' do |current|
        current
      end

      assert_equal item, result
    end

    def test_item_can_custome_not_supported_media_type_in_use_fallback_chain
      item = @manifest['manifest-item-2']
      fallback = item.fallback.fallback
      result = item.use_fallback_chain unsupported: 'image/svg+xml' do |current|
        current
      end

      assert_equal fallback, result
    end

    def test_item_with_absolute_iri_as_href_must_keep_it
      item = @manifest['external-css']
      assert_equal 'http://example.net/stylesheets/common.css', item.iri.to_s
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
