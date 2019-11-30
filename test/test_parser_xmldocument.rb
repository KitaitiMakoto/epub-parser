# coding: utf-8
require_relative "helper"

class TestParserXMLDocument < Test::Unit::TestCase
  def setup
    @container = File.read("test/fixtures/book/META-INF/container.xml")
    @opf = File.read("test/fixtures/book/OPS/ルートファイル.opf")
    @nav = File.read("test/fixtures/book/OPS/nav.xhtml")
    @backends = [:REXML, :Nokogiri, :Oga]
  end

  def test_parse_container
    assert_equal_results @backends do
      container = EPUB::Parser::OCF.new(nil).parse_container(@container)
      [
        container.rootfiles.length,
        container.rootfiles.collect {|rootfile|
          [rootfile.full_path, rootfile.media_type]
        }
      ]
    end
  end

  def test_parse_package_document
    assert_equal_results @backends do
      result = []

      package = EPUB::Parser::Publication.new(@opf).parse

      result << %i[version prefix xml_lang dir id].collect {|attr| package.send(attr)}

      result << EPUB::Metadata::DC_ELEMS.collect {|attr|
        attr = package.metadata.send(attr)
        [
          attr.length,
          attr.collect {|model|
            %i[content id lang dir].collect {|a| model.send(a)}
          }
        ]
      }

      result << package.metadata.metas.collect {|meta|
        %i[property id scheme content name meta_content].collect {|attr| meta.send(attr)}
      }

      result << package.metadata.links.collect {|link|
        %i[href rel id media_type].collect {|attr| link.send(attr)}
      }

      result
    end
  end

  def test_parse_navigation
    assert_equal_results @backends do
      result = []

      nav = EPUB::Parser.parse("test/fixtures/book.epub").nav.content_document

      result << nav.navigations.length

      result << nav.navigations.collect {|item|
        %i[text content_document type].collect {|attr| item.send(attr)}

        item.items.collect {|i|
          %i[text content_document].collect {|attr| i.send(attr)}
        }
      }

      result
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
