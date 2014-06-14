# -*- coding: utf-8 -*-
require_relative 'helper'
require 'epub/searcher'

class TestSearcher < Test::Unit::TestCase
  class TestXHTML < self
    def setup
      nav_path = File.expand_path('../fixtures/book/OPS/nav.xhtml', __FILE__)
      @doc = Nokogiri.XML(open(nav_path))
      @h1 = @doc.search('h1').first
      @nav = @doc.search('nav').first
    end

    def test_no_result
      assert_empty EPUB::Searcher::XHTML.search(@h1, 'no result')
    end

    def test_simple
      assert_equal [[[:text, 0], [:character, 9]]], EPUB::Searcher::XHTML.search(@h1, 'Content')
    end

    def test_multiple_text_result
      assert_equal [[[:text, 0], [:character, 6]], [[:text, 0], [:character, 10]]], EPUB::Searcher::XHTML.search(@h1, 'o')
    end

    def test_text_after_element
      elem = Nokogiri.XML('<root>before<elem>inner</elem>after</root>')

      assert_equal [[[:text, 1], [:character, 0]]], EPUB::Searcher::XHTML.search(elem, 'after')
    end

    def test_entity_reference
      elem = Nokogiri.XML('<root>before&lt;after</root>')

      assert_equal [[[:text, 0], [:character, 6]]], EPUB::Searcher::XHTML.search(elem, '<')
    end

    def test_nested_result
      assert_equal [[[:element, 1, 'ol'], [:element, 1, 'li'], [:element, 1, 'ol'], [:element, 1, 'li'], [:element, 0, 'a'], [:text, 0], [:character, 0]]], EPUB::Searcher::XHTML.search(@nav, '第二節')
    end
  end
end
