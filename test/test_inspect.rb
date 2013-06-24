require_relative 'helper'
require 'epub'

class TestInspect < Test::Unit::TestCase
  class TestPackage < TestInspect
    include EPUB::Publication

    def setup
      @package = Package.new
    end

    def test_package_inspects_object_id
      assert_match (@package.__id__ << 1).to_s(16), @package.inspect
    end

    def test_package_inspects_attributes
      @package.xml_lang = "zh"
      @package.prefix = {'foaf' => 'http://xmlns.com/foaf/spec/'}

      assert_match %Q|@xml_lang="zh"|, @package.inspect
      assert_match %Q|@prefix={"foaf"=>"http://xmlns.com/foaf/spec/"}|, @package.inspect
    end

    def test_package_inspects_content_models
      @package.metadata = Package::Metadata.new

      assert_match '@metadata=#<EPUB::Publication::Package::Metadata:', @package.inspect
    end

    class TestMetadata < TestPackage
      Metadata = Package::Metadata

      def setup
        super
        @metadata = Metadata.new
        @package.metadata = @metadata
      end

      def test_inspects_package_simply
        assert_match(/@package=\#<EPUB::Publication::Package:[^ ]+>/, @metadata.inspect)
      end

      def test_inspects_attributes
        title = Metadata::Title.new
        title.content = 'Book Title'
        @metadata.titles << title

        title_pattern = RUBY_VERSION >= '2.0' ? '@dc_titles=[#<EPUB::Publication::Package::Metadata::Title' : 'Book Title'

        assert_match title_pattern, @metadata.inspect
      end

      def test_dcmes_inspect_includes_class_name
        meta = Package::Metadata::Title.new
        meta.content = 'Book Title'

        title_pattern = RUBY_VERSION >= '2.0' ? '#<EPUB::Publication::Package::Metadata::Title' : 'Book Title'

        assert_match title_pattern, meta.inspect
      end

      def test_dcmes_inspect_includes_instance_variables
        meta = Package::Metadata::DCMES.new
        meta.lang = 'en-US'
        meta.dir = 'rtl'

        if RUBY_VERSION >= '2.0'
          assert_match(/@lang/, meta.inspect)
          assert_match(/en\-US/, meta.inspect)
          assert_match(/@dir/, meta.inspect)
          assert_match(/rtl/, meta.inspect)
        else
          assert_equal '', meta.inspect
        end
      end

      def test_meta_inspect_includes_class_name
        meta = Package::Metadata::Meta.new

        assert_match(/Package::Metadata::Meta/, meta.inspect)
      end

      def test_meta_inspect_includes_instance_variables
        meta = Package::Metadata::Meta.new
        meta.id = 'meta-id'
        meta.content = 'meta content'

        assert_match(/@id/, meta.inspect)
        assert_match(/meta\-id/, meta.inspect)
        assert_match(/@content/, meta.inspect)
        assert_match(/meta content/, meta.inspect)
      end
    end

    class TestManifest < TestPackage
      Manifest = Package::Manifest

      def setup
        super
        @manifest = Manifest.new
        @package.manifest = @manifest
      end

      def test_inspects_package_simply
        assert_match(/@package=\#<EPUB::Publication::Package:[^ ]+>/, @manifest.inspect)
      end

      class TestItem < TestManifest
        def setup
          super
          @item = Manifest::Item.new
          @manifest << @item
        end

        def test_inspects_manifest_simply
          assert_match(/\#<EPUB::Publication::Package::Manifest:[^ ]+>/, @item.inspect)
        end
      end
    end
  end
end
