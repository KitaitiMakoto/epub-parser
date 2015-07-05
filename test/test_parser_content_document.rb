# -*- coding: utf-8 -*-
require_relative 'helper'

class TestParserContentDocument < Test::Unit::TestCase
  def setup
    @manifest = EPUB::Publication::Package::Manifest.new
    %w[item-1.xhtml item-2.xhtml nav.xhtml].each.with_index do |href, index|
      item = EPUB::Publication::Package::Manifest::Item.new
      item.id = index
      item.href = href
      @manifest << item
    end

    @dir = 'test/fixtures/book'
    @parser = EPUB::Parser::ContentDocument.new(@manifest.items.last)
  end

  def test_parse_navigations
    doc = Nokogiri.XML open("#{@dir}/OPS/nav.xhtml")
    navs = @parser.parse_navigations doc
    nav = navs.first

    assert_equal 1, navs.length
    assert_equal 'Table of Contents', nav.heading
    assert_equal 'toc', nav.type

    assert_equal 2, nav.items.length
    assert_equal @manifest.items.first, nav.items.first.item
    assert_equal @manifest.items[1], nav.items[1].items[0].item
    assert_equal @manifest.items[1], nav.items[1].items[1].item

    assert_equal '第四節', nav.items.last.items.last.text

    assert_true nav.hidden?
  end
end
