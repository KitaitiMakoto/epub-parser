# coding: utf-8
require_relative 'helper'
require 'epub/ocf/physical_container'

class TestOCFPhysicalContainer < Test::Unit::TestCase
  def setup
    @container_path = 'test/fixtures/book.epub'
    @path = 'OPS/nav.xhtml'
    @content = File.read(File.join('test/fixtures/book', @path))
  end

  def test_read
    assert_equal @content, EPUB::OCF::PhysicalContainer.read(@container_path, @path).force_encoding('UTF-8')
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

  class TestZipruby < self
    include ConcreteContainer

    def setup
      super
      @class = EPUB::OCF::PhysicalContainer::Zipruby
      @container = @class.new(@container_path)
    end
  end
end
