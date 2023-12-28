require_relative "helper"
require "epub/ocf/physical_container"

class TestOCFPhysicalContainerBase < Test::Unit::TestCase
  def setup
    @container_path = 'test/fixtures/book.epub'
    @path = 'OPS/nav.xhtml'
    @content = File.read(File.join('test/fixtures/book', @path))
  end
end
