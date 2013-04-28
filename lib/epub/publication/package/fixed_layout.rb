module EPUB
  module Publication
    module FixedLayout
      class UnsupportedRenditionLayout < StandardError; end

      class << self
        def included(package_class)
          [
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

      module MetadataMixin
        RENDITION_LAYOUTS = ['reflowable'.freeze, 'pre-paginated'.freeze].freeze

        # @return ["reflowable", "pre-paginated"] the value of rendition:layout
        # @return ["reflowable"] when rendition_layout not set explicitly ever
        def rendition_layout
          layout = metas.find {|meta| meta.property == 'rendition:layout'}
          layout ? layout.content : RENDITION_LAYOUTS.first
        end

        # @param layout ["reflowable", "pre-paginated"] the value of "rendition:layout"
        # @return [String] the value of "rendition:layout"
        # @raise [UnsupportedRenditionLayout] when the argument not in {RENDITION_LAYOUTS}
        def rendition_layout=(layout)
          raise UnsupportedRenditionLayout, layout unless RENDITION_LAYOUTS.include? layout

          layouts_to_be_deleted = RENDITION_LAYOUTS - [layout]
          metas.delete_if {|meta| meta.property == 'rendition:layout' && layouts_to_be_deleted.include?(meta.content)}
          unless metas.any? {|meta| meta.property == 'rendition:layout' && meta.content == layout}
            meta = Package::Metadata::Meta.new
            meta.property = 'rendition:layout'
            meta.content = layout
            metas << meta
          end
          layout
        end

        RENDITION_LAYOUTS.each do |layout|
          method_name_base = layout.gsub('-', '_')
          method_name = "#{method_name_base}="
          define_method method_name do |layout_value|
            new_layout = layout_value ? layout :
              RENDITION_LAYOUTS.find {|l| l != layout}
            self.rendition_layout = new_layout
          end

          method_name = "make_#{method_name_base}"
          define_method method_name do
            self.rendition_layout = layout
          end
          destructive_method_name = "#{method_name_base}!"
          alias_method destructive_method_name, method_name

          method_name = "#{method_name_base}?"
          define_method method_name do
            self.rendition_layout == layout
          end
        end
      end

      module ItemrefMixin
        
      end

      module ItemMixin
        
      end

      module ContentDocumentMixin
        
      end
    end
  end
end
