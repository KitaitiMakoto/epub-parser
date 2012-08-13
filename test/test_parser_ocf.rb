# -*- coding: utf-8 -*-
require File.expand_path 'helper', File.dirname(__FILE__)
require 'epub/parser/ocf'

class TestParserOCF < Test::Unit::TestCase
  def setup
    file = 'test/fixtures/book.epub'
    @zip = Zip::Archive.open(file)
    @parser = EPUB::Parser::OCF.new(@zip)
  end

  def teardown
    @zip.close
  end

  def test_parsed_container_has_one_rootfile
    assert_equal 1, @parser.parse_container.rootfiles.length
  end

  def test_parse_container_can_find_primary_rootfile
    container = @parser.parse_container

    assert_equal 'OPS/ルートファイル.opf', container.rootfile.full_path
  end

  def test_parse
    ocf = @parser.parse

    pend
  end
end

