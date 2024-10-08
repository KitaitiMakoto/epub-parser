# -*- coding: utf-8 -*-
require File.expand_path 'helper', File.dirname(__FILE__)

class TestParserOCF < Test::Unit::TestCase
  def setup
    file = 'test/fixtures/book.epub'
    EPUB::OCF::PhysicalContainer.open(file) {|container|
      @parser = EPUB::Parser::OCF.new(container)
    }
    @container_xml = File.read("test/fixtures/book/META-INF/container.xml")
    @metadata_xml = File.read("test/fixtures/book/META-INF/metadata.xml")
  end

  def test_parsed_container_has_two_rootfiles
    assert_equal 3, @parser.parse_container(@container_xml).rootfiles.length
  end

  def test_parse_container_can_find_primary_rootfile
    container = @parser.parse_container(@container_xml)

    assert_equal 'OPS/ルートファイル.opf', container.rootfile.full_path.to_s
  end

  def test_parse_encryption_do_nothing_excluding_to_have_content
    encryption = @parser.parse_encryption('<root>content</root>')

    assert_equal '<root>content</root>', encryption.content
  end

  def test_parse_metadata_with_unknown_format_do_nothing_excluding_to_have_content
    metadata = @parser.parse_metadata('<root>content</root>')

    assert_equal '<root>content</root>', metadata.content
  end

  def test_parse_metadata_with_multiple_rendition_format_returns_metadata
    metadata = @parser.parse_metadata(@metadata_xml)

    assert_equal 'urn:uuid:A1B0D67E-2E81-4DF5-9E67-A64CBE366809@2011-01-01T12:00:00Z', metadata.release_identifier
  end

  def test_parse
    assert_nothing_raised do
      @parser.parse
    end
  end
end
