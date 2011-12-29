require File.expand_path 'helper', File.dirname(__FILE__)
require 'epub/parser'
require 'fileutils'
require 'tmpdir'

class TestParser < Test::Unit::TestCase
  def setup
    @rootdir = Dir.mktmpdir 'epub-parser'
    @parser = EPUB::Parser.new 'test/fixtures/book.epub', @rootdir
  end

  def teardown
    FileUtils.remove_entry_secure @rootdir
  end

  def test_parse
    pend
  end

  class TestBook < TestParser
    def setup
      super
      @book = @parser.parse
    end

    def test_each_page_by_spine_iterates_items_in_spines_order
      @book.each_page_by_spine do |page|
        assert_instance_of Publication::Package::Manifest::Item, page
      end
    end

    def test_each_content_iterates_items_in_manifest
      @book.each_content do |page|
        assert_instance_of Publication::Package::Manifest::Item, page
      end
    end

    def test_each_content_returns_enumerator_when_no_block_passed
      contents = @book.each_content

      assert_respond_to contents, :each
    end

    def test_enumerator_returned_by_each_content_iterates_items_in_spines_order
      contents = @book.each_content

      contents.each do |page|
        assert_instance_of Publication::Package::Manifest::Item, page
      end
    end
  end
end
