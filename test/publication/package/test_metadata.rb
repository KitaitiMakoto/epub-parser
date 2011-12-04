require File.expand_path '../../helper', File.dirname(__FILE__)
require 'epub/publication/package/metadata'

class TestMetadata < Test::Unit::TestCase
  def setup
    @metadata = Publication::Package::Metadata.new
  end

  def test_attributes
    assert @metadata.respond_to? :contributers=
    assert @metadata.respond_to? :dc_contributers=
    assert @metadata.respond_to? :dc_contributer
  end
end
