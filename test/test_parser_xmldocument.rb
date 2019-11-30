# coding: utf-8
require_relative "helper"

class TestParserXMLDocument < Test::Unit::TestCase
  def setup
    @container = File.read("test/fixtures/book/META-INF/container.xml")
    @opf = File.read("test/fixtures/book/OPS/ルートファイル.opf")
    @nav = File.read("test/fixtures/book/OPS/nav.xhtml")
  end

  def test_parse_container
    EPUB::Parser::XMLDocument.backend = :REXML
    rexml_container = EPUB::Parser::OCF.new(nil).parse_container(@container)
    EPUB::Parser::XMLDocument.backend = :Nokogiri
    nokogiri_container = EPUB::Parser::OCF.new(nil).parse_container(@container)

    assert_equal rexml_container.rootfiles.length, nokogiri_container.rootfiles.length
    rexml_container.rootfiles.each do |rootfile|
      rf = nokogiri_container.rootfiles.find {|rf| rf.full_path == rootfile.full_path}
      assert_equal rootfile.full_path, rf.full_path
      assert_equal rootfile.media_type, rf.media_type
    end
  end

  def test_parse_package_document
    EPUB::Parser::XMLDocument.backend = :REXML
    rexml_package = EPUB::Parser::Publication.new(@opf).parse
    EPUB::Parser::XMLDocument.backend = :Nokogiri
    nokogiri_package = EPUB::Parser::Publication.new(@opf).parse

    %i[version prefix xml_lang dir id].each do |attr|
      assert_equal rexml_package.send(attr), nokogiri_package.send(attr)
    end

    EPUB::Metadata::DC_ELEMS.each do |attr|
      rexml_attr = rexml_package.metadata.send(attr)
      nokogiri_attr = nokogiri_package.metadata.send(attr)

      assert_equal rexml_attr.length, nokogiri_attr.length

      rexml_attr.each_with_index do |model, index|
        %i[content id lang dir].each do |a|
          assert_equal model.send(a), nokogiri_attr[index].send(a)
        end
      end
    end

    rexml_package.metadata.metas.each_with_index do |meta, index|
      %i[property id scheme content name meta_content].each do |attr|
        assert_equal meta.send(attr), nokogiri_package.metadata.metas[index].send(attr)
      end
    end

    rexml_package.metadata.links.each_with_index do |link, index|
      %i[href rel id media_type].each do |attr|
        assert_equal link.send(attr), nokogiri_package.metadata.links[index].send(attr)
      end
    end
  end

  def test_parse_navigation
    EPUB::Parser::XMLDocument.backend = :REXML
    rexml_nav = EPUB::Parser.parse("test/fixtures/book.epub").nav.content_document
    EPUB::Parser::XMLDocument.backend = :Nokogiri
    nokogiri_nav = EPUB::Parser.parse("test/fixtures/book.epub").nav.content_document

    assert_equal rexml_nav.navigations.length, nokogiri_nav.navigations.length

    rexml_nav.navigations.each_with_index do |item, index|
      nokogiri_item = nokogiri_nav.navigations[index]
      %i[text content_document type].each do |attr|
        assert_equal item.send(attr), nokogiri_item.send(attr)
      end

      item.items.each_with_index do |i, index2|
        %i[text content_document].each do |attr|
          assert_equal i.send(attr), nokogiri_item.items[index2].send(attr)
        end
      end
    end
  end

  private

  def assert_equal_results(backends)
    results = backends.collect {|backend|
      EPUB::Parser::XMLDocument.backend = backend
      yield
    }
    expected = results.shift
    results.each do |actual|
      assert_equal expected, actual
    end
  end
end
