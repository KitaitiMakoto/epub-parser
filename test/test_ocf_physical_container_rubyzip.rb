require_relative "helper"
require_relative "test_ocf_physical_container_base"
require "epub/ocf/physical_container/rubyzip"

class TestRubyzip < TestOCFPhysicalContainerBase
  include ConcreteContainer

  def setup
    super
    @class = EPUB::OCF::PhysicalContainer::Rubyzip
    @container = @class.new(@container_path)
  end
end
