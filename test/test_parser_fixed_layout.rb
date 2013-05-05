require_relative 'helper'
require 'epub/parser'

class TestParserFixedLayout < Test::Unit::TestCase
  def test_using_fixed_layout_is_true_when_rendition_property_in_package_prefix
    parser = EPUB::Parser::Publication.new(<<OPF, 'dummy/rootfile.opf')
    <package version="3.0"
             unique-identifier="pub-id"
             xmlns="http://www.idpf.org/2007/opf"
             prefix="rendition: http://www.idpf.org/vocab/rendition/#">
    </package>
OPF
    package = parser.parse_package
    assert_true package.using_fixed_layout?
  end
end
