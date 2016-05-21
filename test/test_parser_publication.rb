# -*- coding: utf-8 -*-
require File.expand_path 'helper', File.dirname(__FILE__)

class TestParserPublication < Test::Unit::TestCase
  def setup
    file = 'test/fixtures/book.epub'
    rootfile = 'OPS/ルートファイル.opf'
    @zip = Zip::Archive.open(file)
    opf = @zip.fopen(rootfile).read
    @parser = EPUB::Parser::Publication.new(opf)
    @package = @parser.parse_package
  end

  def teardown
    @zip.close
  end

  def test_parse_package
    assert_equal '3.0', @package.version
  end

  def test_has_unique_identifier
    @package.metadata = @parser.parse_metadata
    assert_equal 'pub-id', @package.unique_identifier.id
    assert_equal 'da265185-8da8-462d-a146-17dd388f61fc', @package.unique_identifier.to_s
  end

  def test_has_prefixes_for_vocabulary
    expected = {'foaf' => 'http://xmlns.com/foaf/spec/',
                'dbp'  => 'http://dbpedia.org/ontology/'}
    assert_equal expected, @package.prefix
  end

  def test_has_empty_hash_as_prefix_when_no_prefix_attribute
    parser = EPUB::Parser::Publication.new('<package></package>')
    package = parser.parse_package
    assert_empty package.prefix
  end

  class TestParseMetadata < TestParserPublication
    def setup
      super
      @metadata = @parser.parse_metadata
    end

    def test_has_identifier
      assert_equal 'da265185-8da8-462d-a146-17dd388f61fc', @metadata.identifiers.first.content
    end

    def test_identifier_has_scheme_when_qualified_by_attribute
      assert_equal 'ISBN', @metadata.identifiers[1].scheme
    end

    def test_has_unique_identifier
      assert_equal 'da265185-8da8-462d-a146-17dd388f61fc', @metadata.unique_identifier.to_s
    end

    def test_has_five_titles
      assert_equal 5, @metadata.titles.length
    end

    def test_returns_extended_title_as_title_attribute_if_exists
      assert_equal 'The Great Cookbooks of the World: 
        Mon premier guide de cuisson, un Mémoire. 
        The New French Cuisine Masters, Volume Two. 
        Special Anniversary Edition', @metadata.title
    end

    def test_titles_has_order
      titles = @metadata.titles
      assert titles[0] > titles[1]
      assert titles[1] < titles[2]
      assert titles[2] < titles[3]
      assert titles[3] > titles[4]
    end
  end

  class TestParseManifest < TestParserPublication
    def setup
      super
      @package.manifest = @manifest = @parser.parse_manifest
    end

    def test_manifest_has_19_items
      assert_equal 19, @manifest.items.length
    end

    def test_item_has_relative_path_as_href_attribute
      assert_equal 'nav.xhtml', @manifest['nav'].href.to_s
    end

    def test_fallback_attribute_of_item_should_be_item_object
      fallback = @manifest['manifest-item-2'].fallback

      assert_instance_of EPUB::Publication::Package::Manifest::Item, fallback
      assert_equal 'manifest-item-fallback', fallback.id
    end

    def test_item_is_readable
      item = EPUB::Parser.parse('test/fixtures/book.epub').package.manifest.items.first
      doc = Nokogiri.XML item.read

      assert_equal 'html', doc.root.name
    end

    def test_item_unescape_href_when_reading_file
      item = EPUB::Parser.parse('test/fixtures/book.epub').package.manifest['containing-encoded-space']
      doc = Nokogiri.HTML(item.read)
      assert_equal 'Containing Space', (doc/'title').first.content
    end

    def test_iri_of_item_is_case_sensitive
      manifest = EPUB::Parser.parse('test/fixtures/book.epub').package.manifest

      assert_not_equal manifest['large-file-name'].read, manifest['small-file-name'].read
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
      assert_equal 'http://example.net/stylesheets/common.css', item.href.to_s
    end
  end

  class TestParseSpine < TestParserPublication
    def setup
      super
      @spine = @parser.parse_spine
    end

    def atest_each_itemref_yields_itemref_in_order_on_spine_element
      expected = %w[nav manifest-item-1 manifest-item-2 containing-space japanese-filename].map {|idref|
        itemref = EPUB::Publication::Package::Spine::Itemref.new
        itemref.id = nil
        itemref.spine = @spine
        itemref.idref = idref
        itemref.linear = true
        itemref.properties = []
        itemref
      }
      assert_equal expected, @spine.each_itemref.to_a
    end
  end

  class TestParseGuide < TestParserPublication
    def setup
      super
      @package.guide = @guide = @parser.parse_guide
    end

    def test_guide_has_one_reference
      assert_equal 1, @guide.references.length
    end

    def test_guide_has_cover_reference
      assert @guide.cover
      assert_equal 'cover', @guide.cover.type
    end

    def test_reference_refers_item
      @package.manifest = @parser.parse_manifest

      assert_instance_of EPUB::Publication::Package::Manifest::Item, @guide.cover.item
    end
  end

  class TestParseBindings < TestParserPublication
    def setup
      super
      @package.manifest = @parser.parse_manifest
      @package.bindings = @bindings = @parser.parse_bindings(@package.manifest)
    end

    def test_has_one_bindings
      assert @bindings
    end

    def test_bindings_has_one_media_type
      assert_equal 1, @bindings.media_types.length
    end

    def test_bindings_is_accessible_like_hash
      media_type = @bindings.media_types.first
      assert_equal media_type, @bindings['application/x-demo-slideshow']
      assert_nil @bindings['non-existing-media-type']
    end

    def test_media_type_has_media_type_attribute
      assert_equal 'application/x-demo-slideshow', @bindings.media_types.first.media_type
    end

    def test_media_type_has_handler_attribute
      assert_not_nil @bindings.media_types.first.handler
    end

    def test_media_type_refers_item_as_handler
      assert_kind_of EPUB::Publication::Package::Manifest::Item, @bindings.media_types.first.handler
    end

    def test_use_fallback_chain_use_bindings
      item = @package.manifest['slideshow']
      item.use_fallback_chain do |slideshow|
        assert_equal 'impl', slideshow.id
      end
    end
  end
end
