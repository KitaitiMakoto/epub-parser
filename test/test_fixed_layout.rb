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

    def test_layout_setter
      @metadata.rendition_layout = 'reflowable'
      assert_equal 'reflowable', @metadata.rendition_layout

      @metadata.rendition_layout = 'pre-paginated'
      assert_equal 'pre-paginated', @metadata.rendition_layout

      assert_raise FixedLayout::UnsupportedRenditionLayout do
        @metadata.rendition_layout = 'undefined'
      end
    end

    def test_utility_methods_for_rendition_layout_setter
      @metadata.make_pre_paginated
      @metadata.rendition_layout == 'pre-paginated'

      @metadata.make_reflowable
      @metadata.rendition_layout == 'reflowable'

      @metadata.pre_paginated!
      @metadata.rendition_layout == 'pre-paginated'

      @metadata.reflowable!
      @metadata.rendition_layout == 'reflowable'
    end
  end

  class TestItemref < TestFixedLayout
    def setup
      @itemref = Package::Spine::Itemref.new
      @package = Package.new
      @package.metadata = Package::Metadata.new
      @package.spine = Package::Spine.new
      @package.spine << @itemref
    end

    def test_inherits_metadatas_rendition_layout_by_default
      assert_equal 'reflowable', @itemref.rendition_layout

      @package.metadata.rendition_layout = 'pre-paginated'
      assert_equal 'pre-paginated', @itemref.rendition_layout
    end

    def test_overwrite_rendition_layout_of_metadata_when_set_explicitly
      @package.metadata.rendition_layout = 'pre-paginated'
      @itemref.properties << 'rendition:layout-reflowable'
      assert_equal 'reflowable', @itemref.rendition_layout
    end

    def test_can_set_explicitly
      @itemref.rendition_layout = 'pre-paginated'
      assert_equal 'pre-paginated', @itemref.rendition_layout
    end

    def test_can_unset_explicitly
      @itemref.rendition_layout = 'pre-paginated'
      @itemref.rendition_layout = nil
      assert_equal 'reflowable', @itemref.rendition_layout
      assert_not_include @itemref.properties, 'rendition:layout-reflowable'
    end

    def test_property_added_when_rendition_layout_set
      @itemref.rendition_layout = 'pre-paginated'
      assert_include @itemref.properties, 'rendition:layout-pre-paginated'
    end

    def test_opposite_property_removed_if_exists_when_rendition_layout_set
      @itemref.rendition_layout = 'reflowable'
      @itemref.rendition_layout = 'pre-paginated'
      assert_not_include @itemref.properties, 'rendition:layout-reflowable'
    end

    def test_utility_methods
      assert_true @itemref.reflowable?

      @itemref.make_pre_paginated
      assert_false @itemref.reflowable?
      assert_true @itemref.pre_paginated?
      assert_not_include @itemref.properties, 'rendition:layout-reflowbale'
      assert_include @itemref.properties, 'rendition:layout-pre-paginated'
    end
  end

  class TestItem < TestFixedLayout
  end

  class TestContentDocument < TestFixedLayout
    
  end
end
