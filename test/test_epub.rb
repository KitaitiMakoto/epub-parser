require_relative 'helper'
require 'epub/book'

class TestEUPB < Test::Unit::TestCase
  def setup
    @file = 'test/fixtures/book.epub'
  end

  def test_each_page_on_spine_returns_enumerator_when_block_not_given
    book = EPUB::Parser.parse(@file)
    assert_kind_of Enumerator, book.each_page_on_spine
  end

  def test_enumerator_each_page_on_spine_returns_yields_item
    enum = EPUB::Parser.parse(@file).each_page_on_spine
    enum.each do |entry|
      assert_kind_of EPUB::Publication::Package::Manifest::Item, entry
    end
  end
end

