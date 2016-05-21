require_relative 'helper'
require 'epub/parser'

class TestParserFixedLayout < Test::Unit::TestCase
  def test_using_fixed_layout_is_true_when_rendition_property_in_package_prefix
    opf = <<OPF
    <package version="3.0"
             unique-identifier="pub-id"
             xmlns="http://www.idpf.org/2007/opf"
             prefix="rendition: http://www.idpf.org/vocab/rendition/#">
    </package>
OPF
    parser = EPUB::Parser::Publication.new(opf)
    package = parser.parse_package(Nokogiri.XML(opf))
    assert_true package.using_fixed_layout?
  end
end
