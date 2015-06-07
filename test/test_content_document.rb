# -*- coding: utf-8 -*-
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

  def test_read_returns_content_document_as_string
    item = stub
    stub(item).read {'content'}
    content_doc = XHTML.new
    content_doc.item = item
    assert_equal 'content', content_doc.read
  end

  def test_title_returns_value_of_title_element
    content_doc = XHTML.new
    stub(content_doc).raw_document {File.read(File.join(File.dirname(__FILE__), 'fixtures', 'book', 'OPS', '日本語.xhtml'))}
    assert_equal '日本語', content_doc.title
  end

  def test_title_returns_empty_string_when_title_element_not_exist
    content_doc = XHTML.new
    stub(content_doc).raw_document {'content'}
    assert_equal '', content_doc.title
  end

  class TestNavigationDocument < self
    def test_toc_returns_nav_with_type_toc
      navigation = Navigation.new
      toc = Navigation::Navigation.new.tap {|nav| nav.type = 'toc'}
      navigation.navigations << toc

      assert_same toc, navigation.toc
    end

    def test_contents_returns_items_of_toc
      manifest = EPUB::Publication::Package::Manifest.new
      item = EPUB::Publication::Package::Manifest::Item.new
      item.media_type = 'application/xhtml+xml'
      item.properties = %w[nav]
      item.href = Addressable::URI.parse('nav.xhtml')
      stub(item).read {File.read(File.expand_path('../fixtures/book/OPS/nav.xhtml', __FILE__))}
      manifest << item
      nav_doc = EPUB::Parser::ContentDocument.new(item).parse

      assert_equal ['Table of Contents', '一ページ目', '二ページ目', '第一節', '第二節', '第三節', '第四節'], nav_doc.contents.collect(&:text)
    end

    def test_item_hidden_returns_true_when_it_has_some_value
      item = Navigation::Item.new.tap {|item| item.hidden = ''}
      assert_true item.hidden?
    end

    def test_item_hidden_returns_false_when_no_parent_and_no_value
      item = Navigation::Item.new
      assert_false item.hidden?
    end

    def test_item_hidden_cascade_parent_item
      parent = Navigation::Item.new.tap {|item| item.hidden = true}
      child = Navigation::Item.new.tap {|item| item.hidden = nil}
      parent.items << child
      assert_true parent.items.hidden?
      assert_true child.hidden?
    end

    def test_item_is_traversable
      parent = Navigation::Item.new
      child = Navigation::Navigation.new
      grandchild = Navigation::Item.new
      parent.items << child
      child.items << grandchild

      parent.traverse do |item, deps|
        case deps
        when 0
          assert_equal item, parent
        when 1
          assert_equal item, child
        when 2
          assert_equal item, grandchild
        end
      end
    end
  end
end
