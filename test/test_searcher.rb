# -*- coding: utf-8 -*-
require_relative 'helper'
require 'epub/searcher'

class TestSearcher < Test::Unit::TestCase
  class TestXHTML < self
    def setup
      super
      nav_path = File.expand_path('../fixtures/book/OPS/nav.xhtml', __FILE__)
      @doc = Nokogiri.XML(open(nav_path))
      @h1 = @doc.search('h1').first
      @nav = @doc.search('nav').first
    end

    def test_no_result
      assert_empty EPUB::Searcher::XHTML.search(@h1, 'no result')
    end

    def test_simple
      assert_equal results([[[:text, 0], [:character, 9]]]), EPUB::Searcher::XHTML.search(@h1, 'Content')
    end

    def test_multiple_text_result
      assert_equal results([[[:text, 0], [:character, 6]], [[:text, 0], [:character, 10]]]), EPUB::Searcher::XHTML.search(@h1, 'o')
    end

    def test_text_after_element
      elem = Nokogiri.XML('<root>before<elem>inner</elem>after</root>')

      assert_equal results([[[:text, 1], [:character, 0]]]), EPUB::Searcher::XHTML.search(elem, 'after')
    end

    def test_entity_reference
      elem = Nokogiri.XML('<root>before&lt;after</root>')

      assert_equal results([[[:text, 0], [:character, 6]]]), EPUB::Searcher::XHTML.search(elem, '<')
    end

    def test_nested_result
      assert_equal results([[[:element, 1, 'ol'], [:element, 1, 'li'], [:element, 1, 'ol'], [:element, 1, 'li'], [:element, 0, 'a'], [:text, 0], [:character, 0]]]), EPUB::Searcher::XHTML.search(@nav, '第二節')
    end

    private

    def results(results)
      results.collect {|res| result(res)}
    end

    def result(steps)
      EPUB::Searcher::Result.new(steps.collect {|s| step(s)})
    end

    def step(step)
      if step.kind_of? EPUB::Searcher::Result::Step
        step
      else
        EPUB::Searcher::Result::Step.new(*step)
      end
    end

    class TestResult < self
      def setup
        super
        @result = EPUB::Searcher::XHTML.search(@doc, '第二節').first
      end

      def test_to_xpath_and_offset
        assert_equal ['./*[2]/*[1]/*[1]/*[2]/*[2]/*[2]/*[2]/*[1]/text()[1]', 0], @result.to_xpath_and_offset
        assert_equal ['./xhtml:*[2]/xhtml:*[1]/xhtml:*[1]/xhtml:*[2]/xhtml:*[2]/xhtml:*[2]/xhtml:*[2]/xhtml:*[1]/text()[1]', 0], @result.to_xpath_and_offset(true)
      end

      def test_to_cfi
        assert_equal '/4/2/2/4/4/4/4/2:0', @result.to_cfi
      end
    end
  end
end
