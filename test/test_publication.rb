require_relative 'helper'
require 'epub/publication'

class TestPublication < Test::Unit::TestCase
  def test_package_clear_package_attribute_of_submodules_when_attribute_writer_called
    metadata = EPUB::Publication::Package::Metadata.new
    another_metadata = EPUB::Publication::Package::Metadata.new
    package = EPUB::Publication::Package.new

    package.metadata = metadata
    assert_equal metadata.package, package

    package.metadata = another_metadata
    assert_nil metadata.package
  end
end

