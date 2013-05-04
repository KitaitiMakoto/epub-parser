module EPUB
  module Publication
    module FixedLayout
      PREFIX_KEY = 'rendition'.freeze
      PREFIX_VALUE = 'http://www.idpf.org/vocab/rendition/#'.freeze

      RENDITION_PROPERTIES = {
        'layout'      => ['reflowable'.freeze, 'pre-paginated'.freeze].freeze,
        'orientation' => ['auto'.freeze, 'landscape'.freeze, 'portrait'.freeze].freeze,
        'spread'      => ['auto'.freeze, 'none'.freeze, 'landscape'.freeze, 'portrait'.freeze, 'both'.freeze].freeze
      }.freeze

      class UnsupportedRenditionValue < StandardError; end

      class << self
        def included(package_class)
          [
           [Package, PackageMixin],
           [Package::Metadata, MetadataMixin],
           [Package::Spine::Itemref, ItemrefMixin],
           [Package::Manifest::Item, ItemMixin],
           [ContentDocument::XHTML, ContentDocumentMixin],
          ].each do |(base, mixin)|
            base.__send__ :include, mixin
          end
        end
      end

      module Rendition
        # @note Call after defining #rendition_xxx and #renditionn_xxx=
        def def_rendition_methods
          RENDITION_PROPERTIES.each_key do |property|
            alias_method property, "rendition_#{property}"
            alias_method "#{property}=", "rendition_#{property}="
          end
          def_rendition_layout_methods
        end

        def def_rendition_layout_methods
          property = 'layout'
          RENDITION_PROPERTIES[property].each do |value|
            method_name_base = value.gsub('-', '_')
            writer_name = "#{method_name_base}="
            define_method writer_name do |new_value|
              new_prop = new_value ? value : values.find {|l| l != value}
              __send__ "rendition_#{property}=", new_prop
            end

            maker_name = "make_#{method_name_base}"
            define_method maker_name do
              __send__ "rendition_#{property}=", value
            end
            destructive_method_name = "#{method_name_base}!"
            alias_method destructive_method_name, maker_name

            predicate_name = "#{method_name_base}?"
            define_method predicate_name do
              __send__("rendition_#{property}") == value
            end
          end
        end
      end

      module PackageMixin
        # @return [true, false]
        def using_fixed_layout
          prefix.has_key? PREFIX_KEY and
            prefix[PREFIX_KEY] == PREFIX_VALUE
        end
        alias using_fixed_layout? using_fixed_layout

        # @param using_fixed_layout [true, false]
        def using_fixed_layout=(using_fixed_layout)
          if using_fixed_layout
            prefix[PREFIX_KEY] = PREFIX_VALUE
          else
            prefix.delete PREFIX_KEY
          end
        end
      end

      module MetadataMixin
        extend Rendition

        RENDITION_PROPERTIES.each_pair do |property, values|
          define_method "rendition_#{property}" do
            meta = metas.find {|m| m.property == "rendition:#{property}"}
            meta ? meta.content : values.first
          end

          define_method "rendition_#{property}=" do |new_value|
            raise UnsupportedRenditionValue, new_value unless values.include? new_value

            prefixed_property = "rendition:#{property}"
            values_to_be_deleted = values - [new_value]
            metas.delete_if {|meta| meta.property == prefixed_property && values_to_be_deleted.include?(meta.content)}
            unless metas.any? {|meta| meta.property == prefixed_property && meta.content == new_value}
              meta = Package::Metadata::Meta.new
              meta.property = prefixed_property
              meta.content = new_value
              metas << meta
            end
            new_value
          end
        end

        def_rendition_methods
      end

      module ItemrefMixin
        extend Rendition

        PAGE_SPREAD_PROPERTY = 'center'
        PAGE_SPREAD_PREFIX = 'rendition:page-spread-'

        class << self
          # @todo Define using Module#prepend after Ruby 2.0 will become popular
          def included(base)
            base.__send__ :alias_method, :page_spread_without_fixed_layout, :page_spread
            base.__send__ :alias_method, :page_spread_writer_without_fixed_layout, :page_spread=

            prefixed_page_spread_property = "#{PAGE_SPREAD_PREFIX}#{PAGE_SPREAD_PROPERTY}"
            base.__send__ :define_method, :page_spread do
              property = page_spread_without_fixed_layout
              return property if property
              property = properties.find {|prop| prop == prefixed_page_spread_property}
              property ? PAGE_SPREAD_PROPERTY : nil
            end

            base.__send__ :define_method, :page_spread= do |new_value|
              if new_value == PAGE_SPREAD_PROPERTY
                page_spread_writer_without_fixed_layout nil
                properties << prefixed_page_spread_property
              else
                page_spread_writer_without_fixed_layout new_value
              end
              new_value
            end
          end
        end

        RENDITION_PROPERTIES.each do |property, values|
          rendition_property_prefix = "rendition:#{property}-"

          reader_name = "rendition_#{property}"
          define_method reader_name do
            prop_value = properties.find {|prop| prop.start_with? rendition_property_prefix}
            prop_value ? prop_value.gsub(/\A#{Regexp.escape(rendition_property_prefix)}/, '') :
              spine.package.metadata.__send__(reader_name)
          end

          writer_name = "#{reader_name}="
          define_method writer_name do |new_value|
            if new_value.nil?
              properties.delete_if {|prop| prop.start_with? rendition_property_prefix}
              return new_value
            end

            raise UnsupportedRenditionValue, new_value unless values.include? new_value

            values_to_be_deleted = (values - [new_value]).map {|value| "#{rendition_property_prefix}#{value}"}
            properties.delete_if {|prop| values_to_be_deleted.include? prop}
            new_property = "#{rendition_property_prefix}#{new_value}"
            properties << new_property unless properties.any? {|prop| prop == new_property}
            new_value
          end
        end

        def_rendition_methods
      end

      module ItemMixin
        extend Rendition

        RENDITION_PROPERTIES.each_key do |property|
          define_method "rendition_#{property}" do
            itemref.__send__ property
          end

          writer_name = "rendition_#{property}="
          define_method writer_name do |value|
            itemref.__send__ writer_name, value
          end
        end

        def_rendition_methods
      end

      module ContentDocumentMixin
        extend Rendition

        RENDITION_PROPERTIES.each_key do |property|
          reader_name = "rendition_#{property}"
          define_method reader_name do
            item.__send__ reader_name
          end

          writer_name = "rendition_#{property}="
          define_method writer_name do |value|
            item.__send__ writer_name, value
          end
        end

        def_rendition_methods
      end
    end
  end
end
