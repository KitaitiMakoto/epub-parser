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

  begin
    require 'epub/ocf/physical_container/zipruby'
    class TestZipruby < self
      include ConcreteContainer

      def setup
        super
        @class = EPUB::OCF::PhysicalContainer::Zipruby
        @container = @class.new(@container_path)
      end
    end
  rescue LoadError
    warn "Skip TestOPFPhysicalContainer::TestZipruby"
  end

  class TestUnpackedDirectory < self
    include ConcreteContainer

    def setup
      super
      @container_path = @container_path[0..-'.epub'.length-1]
      @class = EPUB::OCF::PhysicalContainer::UnpackedDirectory
      @container = @class.new(@container_path)
    end

    def test_adapter_can_changable
      adapter = EPUB::OCF::PhysicalContainer.adapter
      EPUB::OCF::PhysicalContainer.adapter = @class
      assert_equal @content, EPUB::OCF::PhysicalContainer.read(@container_path, @path).force_encoding('UTF-8')
      EPUB::OCF::PhysicalContainer.adapter = adapter
    end
  end

  class TestArchiveZip < self
    include ConcreteContainer

    def setup
      super
      @class = EPUB::OCF::PhysicalContainer::ArchiveZip
      @container = @class.new(@container_path)
    end
  end

  require "epub/ocf/physical_container/rubyzip"
  class TestRubyzip < self
    include ConcreteContainer

    def setup
      super
      @class = EPUB::OCF::PhysicalContainer::Rubyzip
      @container = @class.new(@container_path)
    end
  end

  class TestUnpackedURI < self
    def setup
      super
      @container_path = 'https://raw.githubusercontent.com/IDPF/epub3-samples/master/30/page-blanche/'
      @class = EPUB::OCF::PhysicalContainer::UnpackedURI
      @container = @class.new(@container_path)
    end

    def test_read
      path = 'META-INF/container.xml'
      content = 'content'
      root_uri = URI(@container_path)
      container_xml_uri = root_uri + path
      stub(root_uri).+ {container_xml_uri}
      stub(container_xml_uri).read {content}

      assert_equal content, @class.new(root_uri).read('META-INF/container.xml')
    end
  end
end
