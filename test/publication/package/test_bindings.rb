require File.expand_path '../../helper', File.dirname(__FILE__)
require 'epub/publication/package/bindings'

include Publication

class TestBindings < Test::Unit::TestCase
  def setup
    @bindings = Package::Bindings.new
    @media_type = Package::Bindings::MediaType.new
  end

  def test_example
    assert false
  end
end
