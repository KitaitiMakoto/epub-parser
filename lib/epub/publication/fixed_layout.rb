module EPUB
  module Publication
    module FixedLayout
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
           [ContentDocument, ContentDocumentMixin],
          ].each do |(base, mixin)|
            base.module_eval do
              include mixin
            end
          end
        end
      end

      module Rendition
        def def_rendition_layout_methods
          RENDITION_PROPERTIES.each_pair do |property, values|
            values.each do |value|
              alias_method property, "rendition_#{property}"
              alias_method "#{property}=", "rendition_#{property}="

              method_name_base = value.gsub('-', '_')
              method_name = "#{method_name_base}="
              define_method method_name do |new_value|
                new_prop = new_value ? value : values.find {|l| l != value}
                __send__ "rendition_#{property}=", new_prop
              end

              method_name = "make_#{method_name_base}"
              define_method method_name do
                __send__ "rendition_#{property}=", value
              end
              destructive_method_name = "#{method_name_base}!"
              alias_method destructive_method_name, method_name

              method_name = "#{method_name_base}?"
              define_method method_name do
                __send__("rendition_#{property}") == value
              end
            end
          end
        end
      end

      module PackageMixin
        # @todo use package.prefix
        attr_writer :using_fixed_layout

        def using_fixed_layout
          !! @using_fixed_layout
        end
        alias using_fixed_layout? using_fixed_layout
      end

      module MetadataMixin
        extend Rendition

        RENDITION_PROPERTIES.each_pair do |property, values|
          define_method "rendition_#{property}" do
            meta = metas.find {|meta| meta.property == "rendition:#{property}"}
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

        def_rendition_layout_methods
      end

      module ItemrefMixin
        extend Rendition

        RENDITION_LAYOUT_PREFIX = 'rendition:layout-'

        RENDITION_PROPERTIES.each do |property, values|
          rendition_property_prefix = "rendition:#{property}-"

          method_name = "rendition_#{property}"
          define_method method_name do
            prop_value = properties.find {|prop| prop.start_with? rendition_property_prefix}
            prop_value ? prop_value.gsub(/\A#{Regexp.escape(rendition_property_prefix)}/o, '') :
              spine.package.metadata.__send__(method_name)
          end
        end

        # @param layout ["reflowable", "pre-paginated", nil]
        # @return ["reflowable", "pre-paginated", nil] the value of "rendition:layout"
        # @raise [UnsupportedRenditionLayout] when the argument not in {RENDITION_LAYOUT} nor nil
        def rendition_layout=(layout)
          if layout.nil?
            properties.delete_if {|prop| prop.start_with? RENDITION_LAYOUT_PREFIX}
            return layout
          end

          raise UnsupportedRenditionValue, layout unless RENDITION_PROPERTIES['layout'].include? layout

          layouts_to_be_deleted = (RENDITION_PROPERTIES['layout'] - [layout]).map {|l| "#{RENDITION_LAYOUT_PREFIX}#{l}"}
          properties.delete_if {|prop| layouts_to_be_deleted.include? prop}
          property = "#{RENDITION_LAYOUT_PREFIX}#{layout}"
          properties << property unless properties.any? {|prop| prop == property}
          layout
        end

        def_rendition_layout_methods
      end

      module ItemMixin
        
      end

      module ContentDocumentMixin
        
      end
    end
  end
end
