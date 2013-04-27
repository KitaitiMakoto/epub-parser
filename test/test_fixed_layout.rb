require_relative 'helper'
require 'epub/book'
require 'epub/publication'
require 'epub/publication/package/fixed_layout'

class EPUB::Publication::Package
  include EPUB::Publication::FixedLayout
end

class TestFixedLayout < Test::Unit::TestCase
  include EPUB::Publication

  class TestMetadata < TestFixedLayout
    def setup
      @metadata = Package::Metadata.new
    end

    def test_default_layout_is_reflowable
      assert_equal 'reflowable', @metadata.rendition_layout
      assert_true @metadata.reflowable?
    end

    def test_deafult_layout_is_not_pre_paginated
      assert_false @metadata.pre_paginated?
    end

    def test_layout_is_pre_paginated_when_has_meta_with_rendition_layout
      meta = Package::Metadata::Meta.new
      meta.property = 'rendition:layout'
      meta.content = 'pre-paginated'
      @metadata.metas << meta
      assert_equal 'pre-paginated', @metadata.rendition_layout
      assert_true @metadata.pre_paginated?
    end

    def test_layout_is_reflowable_when_has_meta_with_rendition_layout
      meta = Package::Metadata::Meta.new
      meta.property = 'rendition:layout'
      meta.content = 'reflowable'
      @metadata.metas << meta
      assert_equal 'reflowable', @metadata.rendition_layout
      assert_true @metadata.reflowable?
    end

    def test_can_set_rendition_layout_by_method_of_metadata
      @metadata.pre_paginated = true
      assert_equal 'pre-paginated', @metadata.rendition_layout
      assert_false @metadata.reflowable?
      assert_true @metadata.pre_paginated?

      @metadata.reflowable = true
      assert_equal 'reflowable', @metadata.rendition_layout
      assert_true @metadata.reflowable?
      assert_false @metadata.pre_paginated?
    end

    def test_remove_meta_for_pre_paginated_when_making_reflowable
      meta = Package::Metadata::Meta.new
      meta.property = 'rendition:layout'
      meta.content = 'pre-paginated'
      @metadata.metas << meta

      @metadata.reflowable = true
      assert_false @metadata.metas.any? {|meta| meta.property == 'rendition:layout' && meta.content == 'pre-paginated'}
    end

    def test_remove_meta_for_reflowable_when_making_pre_paginated
      meta = Package::Metadata::Meta.new
      meta.property = 'rendition:layout'
      meta.content = 'pre-paginated'
      @metadata.metas << meta
      meta = Package::Metadata::Meta.new
      meta.property = 'rendition:layout'
      meta.content = 'reflowable'
      @metadata.metas << meta

      @metadata.pre_paginated = true
      assert_false @metadata.metas.any? {|meta| meta.property == 'rendition:layout' && meta.content == 'reflowable'}
    end
    end
  end

  class TestItemref < TestFixedLayout
    
  end

  class TestItem < TestFixedLayout
  end

  class TestContentDocument < TestFixedLayout
    
  end
end
