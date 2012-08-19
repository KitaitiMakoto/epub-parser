require_relative 'helper'
require 'epub/book'

class TestEUPB < Test::Unit::TestCase
  def setup
    @file = 'test/fixtures/book.epub'
  end

  def test_parse
    book = EPUB::Book.new
    assert_nothing_raised do
      book.parse @file
    end
  end
end

