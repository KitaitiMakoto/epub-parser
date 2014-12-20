# -*- coding: utf-8 -*-
require_relative 'helper'
require 'epub/searcher'

class TestSearcher < Test::Unit::TestCase
  class TestPublication < self
    def setup
      super
      opf_path = File.expand_path('../fixtures/book/OPS/ルートファイル.opf', __FILE__)
      nav_path = File.expand_path('../fixtures/book/OPS/nav.xhtml', __FILE__)
      @package = EPUB::Parser::Publication.new(open(opf_path), 'OPS/ルートファイル.opf').parse
      @package.spine.each_itemref do |itemref|
        stub(itemref.item).read {
          itemref.idref == 'nav' ? File.read(nav_path) : '<html></html>'
        }
      end
    end

    def test_no_result
      assert_empty EPUB::Searcher::Publication.search(@package, 'no result')
    end

    def test_simple
      assert_equal(
        results([
          [[[:element, 2, {:name => 'spine', :id => nil}], [:itemref, 0, {:id => nil}], [:element, 0, {:name => 'head', :id => nil}], [:element, 0, {:name => 'title', :id => nil}], [:text, 0]], [[:character, 9]], [[:character, 16]]],
          [[[:element, 2, {:name => 'spine', :id => nil}], [:itemref, 0, {:id => nil}], [:element, 1, {:name => 'body', :id => nil}], [:element, 0, {:name => 'div', :id => nil}], [:element, 0, {:name => 'nav', :id => 'idid'}], [:element, 0, {:name => 'hgroup', :id => nil}], [:element, 1, {:name => 'h1', :id => nil}], [:text, 0]], [[:character, 9]], [[:character, 16]]]
        ]),
        EPUB::Searcher::Publication.search(@package, 'Content')
      )
    end

    class TesetResult < self
      def test_to_cfi_s
        assert_equal '/6/2!/4/2/2[idid]/2/4/1,:9,:16', EPUB::Searcher::Publication.search(@package, 'Content').last.to_cfi_s
      end
    end
  end

  class TestXHTML < self
    def setup
      super
      nav_path = File.expand_path('../fixtures/book/OPS/nav.xhtml', __FILE__)
      @doc = Nokogiri.XML(open(nav_path))
      @h1 = @doc.search('h1').first
      @nav = @doc.search('nav').first
    end

    module TestSearch
      def test_no_result
        assert_empty @searcher.search(@h1, 'no result')
      end

      def test_simple
        assert_equal results([[[[:text, 0]], [[:character, 9]], [[:character, 16]]]]), @searcher.search(@h1, 'Content')
      end

      def test_multiple_text_result
        assert_equal results([[[[:text, 0]], [[:character, 6]], [[:character, 7]]], [[[:text, 0]], [[:character, 10]], [[:character, 11]]]]), @searcher.search(@h1, 'o')
      end

      def test_text_after_element
        elem = Nokogiri.XML('<root><elem>inner</elem>after</root>')

        assert_equal results([[[[:text, 1]], [[:character, 0]], [[:character, 5]]]]), @searcher.search(elem, 'after')
      end

      def test_entity_reference
        elem = Nokogiri.XML('<root>before&lt;after</root>')

        assert_equal results([[[[:text, 0]], [[:character, 6]], [[:character, 7]]]]), @searcher.search(elem, '<')
      end

      def test_nested_result
        assert_equal results([[[[:element, 1, {:name => 'ol', :id => nil}], [:element, 1, {:name => 'li', :id => nil}], [:element, 1, {:name => 'ol', :id => nil}], [:element, 1, {:name => 'li', :id => nil}], [:element, 0, {:name => 'a', :id => nil}], [:text, 0]], [[:character, 0]], [[:character, 3]]]]), @searcher.search(@nav, '第二節')
      end

      def test_img
        assert_equal [result([[[:element, 1, {:name => 'ol', :id => nil}], [:element, 1, {:name => 'li', :id => nil}], [:element, 1, {:name => 'ol', :id => nil}], [:element, 2, {:name => 'li', :id => nil}], [:element, 0, {:name => 'a', :id => nil}], [:element, 0, {:name => 'img', :id => nil}]], nil, nil])], @searcher.search(@nav, '第三節')
      end
    end

    class TestRestricted < self
      include TestSearch

      def setup
        super
        @searcher = EPUB::Searcher::XHTML::Restricted
      end
    end

    class TestSeamless < self
      include TestSearch

      def setup
        super
        @searcher = EPUB::Searcher::XHTML::Seamless
      end

      def test_seamless
        elem = Nokogiri.XML('<root>This <em>includes</em> a child element.</root>')
        assert_equal results([[[], [[:text, 0], [:character, 0]], [[:text, 1], [:character, 17]]]]), @searcher.search(elem, 'This includes a child element.')
      end
    end

    class TestResult < self
      def setup
        super
        @result = EPUB::Searcher::XHTML::Restricted.search(@doc, '第二節').first
      end

      def test_to_xpath_and_offset
        assert_equal ['./*[2]/*[1]/*[1]/*[2]/*[2]/*[2]/*[2]/*[1]/text()[1]', 0], @result.to_xpath_and_offset
        assert_equal ['./xhtml:*[2]/xhtml:*[1]/xhtml:*[1]/xhtml:*[2]/xhtml:*[2]/xhtml:*[2]/xhtml:*[2]/xhtml:*[1]/text()[1]', 0], @result.to_xpath_and_offset(true)
      end

      def test_to_cfi_s
        assert_equal '/4/2/2[idid]/4/4/4/4/2/1,:0,:3', @result.to_cfi_s
      end

      def test_to_cfi_s_img
        assert_equal '/4/2/2[idid]/4/4/4/6/2/2', EPUB::Searcher::XHTML::Restricted.search(@doc, '第三節').first.to_cfi_s
      end
    end
  end

  private

  def results(results)
    results.collect {|res| result(res)}
  end

  def result(steps_triple)
    EPUB::Searcher::Result.new(*steps_triple.collect {|steps|
      steps ? steps.collect {|s| step(s)} : steps
    })
  end

  def step(step)
    EPUB::Searcher::Result::Step.new(*step)
  end
end
