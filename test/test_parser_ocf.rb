# -*- coding: utf-8 -*-
require File.expand_path 'helper', File.dirname(__FILE__)

class TestParserOCF < Test::Unit::TestCase
  def setup
    file = 'test/fixtures/book.epub'
    @zip = Zip::Archive.open(file)
    @parser = EPUB::Parser::OCF.new(@zip)
    @container_xml = @zip.fopen('META-INF/container.xml').read
  end

  def teardown
    @zip.close
  end

  def test_parsed_container_has_one_rootfile
    assert_equal 1, @parser.parse_container(@container_xml).rootfiles.length
  end

  def test_parse_container_can_find_primary_rootfile
    container = @parser.parse_container(@container_xml)

    assert_equal 'OPS/ルートファイル.opf', container.rootfile.full_path
  end

  def test_parse_encryption_do_nothing_excluding_to_have_content
    encryption = @parser.parse_encryption('content')

    assert_equal 'content', encryption.content
  end

  def test_parse
    assert_nothing_raised do
      @parser.parse
    end
  end
end

