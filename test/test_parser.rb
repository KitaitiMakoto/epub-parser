# coding: utf-8
require File.expand_path 'helper', File.dirname(__FILE__)

class MyBook
  include EPUB::Book::Features
end

class TestParser < Test::Unit::TestCase
  def setup
    @parser = EPUB::Parser.new 'test/fixtures/book.epub'
  end

  def test_parse
    assert_instance_of EPUB::Book, @parser.parse

    book = Object.new
    book.extend EPUB::Book::Features
    assert_nothing_raised do
      EPUB::Parser.parse('test/fixtures/book.epub', book: book)
    end
    assert_kind_of EPUB::Book::Features, EPUB::Parser.parse('test/fixtures/book.epub', book: book)

    assert_nothing_raised do
      EPUB::Parser.parse('test/fixtures/book.epub', class: MyBook)
    end
    assert_kind_of EPUB::Book::Features, EPUB::Parser.parse('test/fixtures/book.epub', class: MyBook)
  end

  def test_parse_from_file_system
    adapter = EPUB::OCF::PhysicalContainer.adapter
    begin
      EPUB::OCF::PhysicalContainer.adapter = :UnpackedDirectory
      epub = EPUB::Parser.parse('test/fixtures/book')
      assert_instance_of EPUB::Book, epub
      assert_equal 'Mon premier guide de cuisson, un Mémoire', epub.main_title
    ensure
      EPUB::OCF::PhysicalContainer.adapter = adapter
    end
  end

  def test_can_specify_container_adapter_when_parsing_individually
    epub = EPUB::Parser.parse('test/fixtures/book', container_adapter: :UnpackedDirectory)

    assert_equal 'Mon premier guide de cuisson, un Mémoire', epub.main_title
    assert_equal File.read('test/fixtures/book/OPS/nav.xhtml'), epub.nav.read
    assert_equal EPUB::OCF::PhysicalContainer::UnpackedDirectory, epub.container_adapter
    assert_equal EPUB::OCF::PhysicalContainer::ArchiveZip, EPUB::OCF::PhysicalContainer.adapter
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
