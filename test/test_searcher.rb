# -*- coding: utf-8 -*-
require_relative 'helper'
require 'epub/searcher'
require 'epub/cfi'

class TestSearcher < Test::Unit::TestCase
  class TestPublication < self
    def setup
      super
      opf_path = File.expand_path('../fixtures/book/OPS/ルートファイル.opf', __FILE__)
      nav_path = File.expand_path('../fixtures/book/OPS/nav.xhtml', __FILE__)
      @package = EPUB::Parser::Publication.new(File.read(opf_path)).parse
      @package.spine.each_itemref do |itemref|
        stub(itemref.item).read {
          itemref.idref == 'nav' ? File.read(nav_path) : '<html></html>'
        }
      end
      stub(@package).full_path {"OPS/ルートファイル.opf"}
    end

    def test_no_result
      assert_empty EPUB::Searcher::Publication.search_text(@package, 'no result')
    end

    def test_simple
      assert_equal(
        results([
          [[[:element, 2, {:name => 'spine', :id => nil}], [:itemref, 0, {:id => nil}], [:element, 0, {:name => 'head', :id => nil}], [:element, 0, {:name => 'title', :id => nil}], [:text, 0]], [[:character, 9]], [[:character, 16]]],
          [[[:element, 2, {:name => 'spine', :id => nil}], [:itemref, 0, {:id => nil}], [:element, 1, {:name => 'body', :id => nil}], [:element, 0, {:name => 'div', :id => nil}], [:element, 0, {:name => 'nav', :id => 'idid'}], [:element, 0, {:name => 'hgroup', :id => nil}], [:element, 1, {:name => 'h1', :id => nil}], [:text, 0]], [[:character, 9]], [[:character, 16]]],
          [[[:element, 2, {:name => 'spine', :id => nil}], [:itemref, 0, {:id => nil}], [:element, 1, {:name => 'body', :id => nil}], [:element, 0, {:name => 'div', :id => nil}], [:element, 1, {:name => 'nav', :id => nil}], [:element, 1, {:name => 'ol', :id => nil}], [:element, 0, {:name => 'li', :id => nil}], [:element, 0, {:name => 'a', :id => nil}], [:text, 0]], [[:character, 9]], [[:character, 16]]]
        ]),
        EPUB::Searcher::Publication.search_text(@package, 'Content')
      )
    end

    def test_search_element_xpath_without_namespaces
      assert_equal(
        [
          "epubcfi(/6/2!/4/2/2[idid]/4/2/2)",
          "epubcfi(/6/2!/4/2/2[idid]/4/4/4/2/2)",
          "epubcfi(/6/2!/4/2/2[idid]/4/4/4/4/2)",
          "epubcfi(/6/2!/4/2/2[idid]/4/4/4/6/2)",
          "epubcfi(/6/2!/4/2/2[idid]/4/4/4/8/2)",
          "epubcfi(/6/2!/4/2/4/4/2/2)",
          "epubcfi(/6/2!/4/2/4/4/4/2)"
        ],
        EPUB::Searcher::Publication.search_element(@package, xpath: './/xhtml:a').collect {|result| result[:location]}.map(&:to_s)
      )
    end

    def test_search_element_xpath_with_namespaces
      assert_equal(
        [
          "epubcfi(/6/2!/4/2/2[idid]/4/2/2)",
          "epubcfi(/6/2!/4/2/2[idid]/4/4/4/2/2)",
          "epubcfi(/6/2!/4/2/2[idid]/4/4/4/4/2)",
          "epubcfi(/6/2!/4/2/2[idid]/4/4/4/6/2)",
          "epubcfi(/6/2!/4/2/2[idid]/4/4/4/8/2)",
          "epubcfi(/6/2!/4/2/4/4/2/2)",
          "epubcfi(/6/2!/4/2/4/4/4/2)"
        ],
        EPUB::Searcher::Publication.search_element(@package, xpath: './/customnamespace:a', namespaces: {'customnamespace' => 'http://www.w3.org/1999/xhtml'}).collect {|result| result[:location]}.map(&:to_s)
      )
    end

    def test_search_element_css_selector
      assert_equal(
        [
          "epubcfi(/6/2!/4/2/2[idid]/4/2)",
          "epubcfi(/6/2!/4/2/2[idid]/4/4)",
          "epubcfi(/6/2!/4/2/2[idid]/4/4/4/2)",
          "epubcfi(/6/2!/4/2/2[idid]/4/4/4/4)",
          "epubcfi(/6/2!/4/2/2[idid]/4/4/4/6)",
          "epubcfi(/6/2!/4/2/2[idid]/4/4/4/8)",
          "epubcfi(/6/2!/4/2/4/4/2)",
          "epubcfi(/6/2!/4/2/4/4/4)"
        ],
        EPUB::Searcher::Publication.search_element(@package, css: 'ol > li').collect {|result| result[:location]}.map(&:to_s)
      )
    end

    class TesetResult < self
      def test_to_cfi
        assert_equal 'epubcfi(/6/2!/4/2/2[idid]/2/4/1,:9,:16)', EPUB::Searcher::Publication.search_text(@package, 'Content').last.to_cfi.to_s
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
        assert_empty @searcher.search_text(@h1, 'no result')
      end

      def test_simple
        assert_equal results([[[[:text, 0]], [[:character, 9]], [[:character, 16]]]]), @searcher.search_text(@h1, 'Content')
      end

      def test_multiple_text_result
        assert_equal results([[[[:text, 0]], [[:character, 6]], [[:character, 7]]], [[[:text, 0]], [[:character, 10]], [[:character, 11]]]]), @searcher.search_text(@h1, 'o')
      end

      def test_text_after_element
        elem = Nokogiri.XML('<root><elem>inner</elem>after</root>')

        assert_equal results([[[[:text, 1]], [[:character, 0]], [[:character, 5]]]]), @searcher.search_text(elem, 'after')
      end

      def test_entity_reference
        elem = Nokogiri.XML('<root>before&lt;after</root>')

        assert_equal results([[[[:text, 0]], [[:character, 6]], [[:character, 7]]]]), @searcher.search_text(elem, '<')
      end

      def test_nested_result
        assert_equal results([[[[:element, 1, {:name => 'ol', :id => nil}], [:element, 1, {:name => 'li', :id => nil}], [:element, 1, {:name => 'ol', :id => nil}], [:element, 1, {:name => 'li', :id => nil}], [:element, 0, {:name => 'a', :id => nil}], [:text, 0]], [[:character, 0]], [[:character, 3]]]]), @searcher.search_text(@nav, '第二節')
      end

      def test_img
        assert_equal [result([[[:element, 1, {:name => 'ol', :id => nil}], [:element, 1, {:name => 'li', :id => nil}], [:element, 1, {:name => 'ol', :id => nil}], [:element, 2, {:name => 'li', :id => nil}], [:element, 0, {:name => 'a', :id => nil}], [:element, 0, {:name => 'img', :id => nil}]], nil, nil])], @searcher.search_text(@nav, '第三節')
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
        assert_equal results([[[], [[:text, 0], [:character, 0]], [[:text, 1], [:character, 17]]]]), @searcher.search_text(elem, 'This includes a child element.')
      end
    end

    class TestResult < self
      def setup
        super
        @result = EPUB::Searcher::XHTML::Restricted.search_text(@doc, '第二節').first
      end

      def test_to_cfi
        assert_equal 'epubcfi(/4/2/2[idid]/4/4/4/4/2/1,:0,:3)', @result.to_cfi.to_s
      end

      def test_to_cfi_img
        assert_equal 'epubcfi(/4/2/2[idid]/4/4/4/6/2/2)', EPUB::Searcher::XHTML::Restricted.search_text(@doc, '第三節').first.to_cfi.to_s
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
