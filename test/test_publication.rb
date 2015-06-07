require_relative 'helper'
require 'epub/publication'

class TestPublication < Test::Unit::TestCase
  include EPUB::Publication
  def setup
    @package = EPUB::Publication::Package.new
  end

  def test_package_clear_package_attribute_of_submodules_when_attribute_writer_called
    metadata = EPUB::Publication::Package::Metadata.new
    another_metadata = EPUB::Publication::Package::Metadata.new

    @package.metadata = metadata
    assert_equal metadata.package, @package

    @package.metadata = another_metadata
    assert_nil metadata.package
  end

  class TestMetadata < TestPublication
    def test_meta_refines_setter_connect_refinee_to_the_meta
      refiner = Package::Metadata::Meta.new
      refinee = Package::Metadata::Meta.new
      refiner.refines = refinee
      assert_same refinee.refiners.first, refiner
    end

    def test_link_refines_setter_connect_refinee_to_the_link
      refiner = Package::Metadata::Link.new
      refinee = Package::Metadata::Meta.new
      refiner.refines = refinee
      assert_same refinee.refiners.first, refiner
    end

    def test_title_returns_extended_title_when_it_exists
      extended_title = Package::Metadata::Title.new
      extended_title.id = 'extended-title'
      extended_title.content = 'Extended Title'
      extended_refiner = Package::Metadata::Meta.new
      extended_refiner.property = 'title-type'
      extended_refiner.content = 'extended'
      extended_refiner.refines = extended_title
      extended_order = Package::Metadata::Meta.new
      extended_order.property = 'display-seq'
      extended_order.content = 2
      extended_order.refines = extended_title

      main_title = Package::Metadata::Title.new
      main_title.id = 'main-title'
      main_title.content = 'Main Title'
      main_refiner = Package::Metadata::Meta.new
      main_refiner.property = 'title-type'
      main_refiner.content = 'main'
      main_refiner.refines = main_title
      main_order = Package::Metadata::Meta.new
      main_order.property = 'display-seq'
      main_order.content = 1
      main_order.refines = main_title

      package = Package::Metadata.new
      package.titles << main_title
      package.titles << extended_title

      assert_equal 'Extended Title', package.title
    end

    def test_title_returns_compositted_title_when_it_is_not_empty
      main_title = Package::Metadata::Title.new
      main_title.id = 'main-title'
      main_title.content = 'main title'
      main_refiner = Package::Metadata::Meta.new
      main_refiner.property = 'title-type'
      main_refiner.content = 'main'
      main_refiner.refines = main_title
      main_order = Package::Metadata::Meta.new
      main_order.property = 'display-seq'
      main_order.content = 1
      main_order.refines = main_title

      subtitle = Package::Metadata::Title.new
      subtitle.id = 'subtitle'
      subtitle.content = 'subtitle'
      sub_refiner = Package::Metadata::Meta.new
      sub_refiner.property = 'title-type'
      sub_refiner.content = 'subtitle'
      sub_refiner.refines = subtitle
      sub_order = Package::Metadata::Meta.new
      sub_order.property = 'display-seq'
      sub_order.content = 2
      sub_order.refines = subtitle

      package = Package::Metadata.new
      package.titles << main_title << subtitle

      assert_equal "main title\nsubtitle", package.title
    end

    def test_title_returns_main_title_when_no_title_has_order
      main_title = Package::Metadata::Title.new
      main_title.id = 'main-title'
      main_title.content = 'main title'
      main_refiner = Package::Metadata::Meta.new
      main_refiner.property = 'title-type'
      main_refiner.content = 'main'
      main_refiner.refines = main_title

      subtitle = Package::Metadata::Title.new
      subtitle.id = 'subtitle'
      subtitle.content = 'subtitle'
      sub_refiner = Package::Metadata::Meta.new
      sub_refiner.property = 'title-type'
      sub_refiner.content = 'subtitle'
      sub_refiner.refines = subtitle

      package = Package::Metadata.new
      package.titles << subtitle << main_title

      assert_equal "main title", package.title
    end

    def test_meta_refining_publication_is_primary_expression
      meta = Package::Metadata::Meta.new
      meta.property = 'dcterms:modified'

      assert_true meta.primary_expression?
    end

    def test_meta_refining_other_element_is_subexpression
      title = Package::Metadata::Title.new
      title.id = 'title'
      meta = Package::Metadata::Meta.new
      meta.refines = title

      assert_true meta.subexpression?
    end

    class TestIdentifier < self
      def setup
        @identifier = Package::Metadata::Identifier.new
      end

      def test_is_isbn_when_refined_by_onix_scheme
        meta = Package::Metadata::Meta.new
        meta.property = 'identifier-type'
        meta.scheme = 'onix:codelist5'
        meta.content = '02'
        meta.refines = @identifier

        assert_true @identifier.isbn?
      end

      def test_is_isbn_when_qualified_by_attribute
        @identifier.content = '0000000000'
        @identifier.scheme = 'ISBN'

        assert_true @identifier.isbn?
      end

      def test_is_isbn_when_content_is_isbn_urn
        @identifier.content = 'urn:isbn:0000000000'

        assert_true @identifier.isbn?
      end

      def test_is_not_isbn_when_no_refiner_nor_scheme
        assert_false @identifier.isbn?
      end

      def test_refiner_take_precedence_over_scheme_for_isbn
        @identifier.content = '0000000000000'
        @identifier.scheme = 'something'
        meta = Package::Metadata::Meta.new
        meta.property = 'identifier-type'
        meta.scheme = 'onix:codelist5'
        meta.content = '15'
        meta.refines = @identifier

        assert_true @identifier.isbn?
      end
    end
  end

  class TestManifest < TestPublication
    include EPUB::Publication

    def setup
      @manifest = EPUB::Publication::Package::Manifest.new
      @nav1 = EPUB::Publication::Package::Manifest::Item.new
      @nav1.id = 'nav1'
      @nav1.properties = %w[nav]
      @nav2 = EPUB::Publication::Package::Manifest::Item.new
      @nav2.id = 'nav2'
      @nav2.properties = %w[nav]
      @item = EPUB::Publication::Package::Manifest::Item.new
      @item.id = 'item'
      @cover_image = EPUB::Publication::Package::Manifest::Item.new
      @cover_image.id = 'cover-image'
      @cover_image.properties = %w[cover-image]
      @manifest << @nav1 << @item << @nav2 << @cover_image
    end

    def test_each_item_returns_enumerator_when_no_block_given
      assert_instance_of Enumerator, @manifest.each_item
    end

    def test_each_nav_iterates_over_items_with_nav_property
      navs = [@nav1, @nav2]
      i = 0
      @manifest.each_nav do |nav|
        assert_same navs[i], nav
        i += 1
      end
    end

    def test_each_nav_returns_iterable_object_when_no_block_given
      navs = [@nav1, @nav2]

      assert_respond_to @manifest.each_nav, :each
      @manifest.each_nav.with_index do |nav, i|
        assert_same navs[i], nav
      end
    end

    def test_navs_iterates_over_items_with_nav_property
      navs = [@nav1, @nav2]
      @manifest.navs.each_with_index do |nav, i|
        assert_same navs[i], nav
      end
    end

    def test_nav_returns_first_item_with_nav_property
      assert_same @nav1, @manifest.nav
    end

    def test_cover_image_returns_item_with_cover_image_property
      assert_same @cover_image, @manifest.cover_image
    end

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

      def test_can_refer_itemref_which_refers_self
        itemref = stub!
        stub(itemref).idref {'item'}
        item = Package::Manifest::Item.new
        item.id = 'item'
        stub(item).manifest.stub!.package.stub!.spine.stub!.itemrefs {[itemref]}

        assert_same itemref, item.itemref
      end

      def test_xhtml_returns_true_when_xhtml
        item = Package::Manifest::Item.new
        item.media_type = 'application/xhtml+xml'

        assert_true item.xhtml?
      end

      def test_xhtml_returns_false_when_not_xhtml
        item = Package::Manifest::Item.new
        item.media_type = 'text/css'

        assert_false item.xhtml?
      end

      def test_find_item_by_relative_iri_returns_item_which_has_resolved_iri_as_href
        manifest = Package::Manifest.new
        manifest << xhtml_item = Package::Manifest::Item.new.tap {|item| item.href = Addressable::URI.parse('text/01.xhtml')}
        manifest << image_item = Package::Manifest::Item.new.tap {|item| item.href = Addressable::URI.parse('image/01.png')}

        assert_equal image_item, xhtml_item.find_item_by_relative_iri(Addressable::URI.parse('../image/01.png'))
      end

      def test_find_item_by_relative_iri_returns_nil_when_no_item_found
        manifest = Package::Manifest.new
        manifest << xhtml_item = Package::Manifest::Item.new.tap {|item| item.href = Addressable::URI.parse('text/01.xhtml')}

        assert_nil xhtml_item.find_item_by_relative_iri(Addressable::URI.parse('../image/01.png'))
      end

      data('UTF-8'     => [Encoding::UTF_8,     'utf-8-encoded'],
           'EUC-JP'    => [Encoding::EUC_JP,    'euc-jp-encoded'],
           'Shift-JIS' => [Encoding::Shift_JIS, 'shift_jis-encoded'])
      def test_read_detects_encoding_automatically(data)
        encoding, id = data
        epub = EPUB::Parser.parse('test/fixtures/book.epub')
        item = epub.package.manifest[id]
        assert_equal encoding, item.read.encoding
      end
    end
  end

  class TestSpine < TestPublication
    class TestItemref < TestSpine
      def setup
        super
        @itemref = Package::Spine::Itemref.new
      end

      def test_default_page_spread_is_nil
        assert_nil @itemref.page_spread
      end

      def test_can_set_page_spread
        @itemref.page_spread = 'left'

        assert_equal 'left', @itemref.page_spread
        assert_include @itemref.properties, 'page-spread-left'
      end

      def test_page_spread_is_exclusive
        @itemref.page_spread = 'left'
        @itemref.page_spread = 'right'

        assert_not_include @itemref.properties, 'page-spread-left'
      end

      def test_can_set_item
        package = Package.new
        item = Package::Manifest::Item.new
        item.id = 'item'
        manifest = Package::Manifest.new
        spine = Package::Spine.new
        manifest << item
        spine << @itemref
        package.manifest = manifest
        package.spine = spine

        @itemref.item = item

        assert_equal 'item', @itemref.idref
        assert_include spine.items, item
        assert_same item, @itemref.item
      end

      def test_itemref_equals_itemref_with_same_attributes
        base = Package::Spine::Itemref.new
        another = Package::Spine::Itemref.new
        [base, another].each do |itemref|
          [:spine, :idref, :id].each do |attr|
            itemref.__send__ "#{attr}=", attr.to_s
          end
          itemref.linear = false
        end
        base.properties = ['property1', 'property2']
        another.properties = ['property2', 'property1']

        assert_true base == another

        base.linear = true
        another.linear = 'yes'

        assert_true base == another
      end

      def test_itemref_doesnt_equal_itemref_with_different_attributes
        base = Package::Spine::Itemref.new
        another = Package::Spine::Itemref.new
        [base, another].each do |itemref|
          [:spine, :idref, :id].each do |attr|
            itemref.__send__ "#{attr}=", attr.to_s
          end
          itemref.linear = false
        end
        base.properties = ['property1', 'property2']
        another.properties = ['property1', 'property2', 'property3']

        assert_false base == another
      end
    end
  end
end
