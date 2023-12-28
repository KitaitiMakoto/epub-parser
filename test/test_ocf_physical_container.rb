# coding: utf-8
require_relative "test_ocf_physical_container_base"

class TestOCFPhysicalContainer < TestOCFPhysicalContainerBase
  def test_read
    assert_equal @content, EPUB::OCF::PhysicalContainer.read(@container_path, @path).force_encoding('UTF-8')
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
