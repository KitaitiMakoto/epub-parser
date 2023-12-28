begin
  require "epub/ocf/physical_container/zipruby"
  require_relative "test_ocf_physical_container_base"

  class TestZipruby < TestOCFPhysicalContainerBase
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
