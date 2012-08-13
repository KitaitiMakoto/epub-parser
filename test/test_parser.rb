require File.expand_path 'helper', File.dirname(__FILE__)
require 'epub/parser'
require 'fileutils'

class TestParser < Test::Unit::TestCase
  def setup
    @parser = EPUB::Parser.new 'test/fixtures/book.epub'
  end

  def test_parse
    pend
  end

  class TestBook < TestParser
    def setup
      super
      @book = @parser.parse
    end

    def test_each_page_on_spine_iterates_items_in_spines_order
      @book.each_page_on_spine do |page|
        assert_instance_of EPUB::Publication::Package::Manifest::Item, page
      end
    end

    def test_each_content_iterates_items_in_manifest
      @book.each_content do |page|
        assert_instance_of EPUB::Publication::Package::Manifest::Item, page
      end
    end

    def test_each_content_returns_enumerator_when_no_block_passed
      contents = @book.each_content

      assert_respond_to contents, :each
    end

    def test_enumerator_returned_by_each_content_iterates_items_in_spines_order
      contents = @book.each_content

      contents.each do |page|
        assert_instance_of EPUB::Publication::Package::Manifest::Item, page
      end
    end
  end
end
