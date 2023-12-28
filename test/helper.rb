Encoding.default_external = 'UTF-8'
require 'simplecov'
SimpleCov.start do
  add_filter /test|deps/
end

require 'pp'
require 'test/unit'
require 'test/unit/rr'
require 'test/unit/notify'
if ENV["PRETTY_BACKTRACE"]
  require 'pretty_backtrace'
  PrettyBacktrace.enable
end

require 'epub/parser'
if ENV["XML_BACKEND"]
  EPUB::Parser::XMLDocument.backend = ENV["XML_BACKEND"].to_sym
end

module ConcreteContainer
  def test_class_method_open
    @class.open @container_path do |container|
      assert_instance_of @class, container
      assert_equal @content, container.read(@path).force_encoding('UTF-8')
      assert_equal File.read('test/fixtures/book/OPS/日本語.xhtml'), container.read('OPS/日本語.xhtml').force_encoding('UTF-8')
    end
  end

  def test_class_method_read
    assert_equal @content, @class.read(@container_path, @path).force_encoding('UTF-8')
  end

  def test_open_yields_over_container_with_opened_archive
    @container.open do |container|
      assert_instance_of @class, container
    end
  end

  def test_container_in_open_block_can_readable
    @container.open do |container|
      assert_equal @content, container.read(@path).force_encoding('UTF-8')
    end
  end

  def test_read
    assert_equal @content, @container.read(@path).force_encoding('UTF-8')
  end
end
