require_relative 'helper'
require 'epub/parser/content_document'

class TestParserContentDocument < Test::Unit::TestCase
  def setup
    @dir = 'test/fixtures/book'
    @parser = EPUB::Parser::ContentDocument.new
  end

  def test_parse_navigations
    doc = Nokogiri.XML open("#{@dir}/OPS/nav.xhtml")
    navs = @parser.parse_navigations doc

    assert_equal 1, navs.length
    assert_equal 'Table of Contents', navs.first.heading
  end
end
