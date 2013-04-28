module EPUB
  module Publication
    module FixedLayout
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

        # @return [String] the value of rendition:layout. "reflowable" or "pre-paginated"
        def rendition_layout
          layout = metas.find {|meta| meta.property == 'rendition:layout'}
          layout ? layout.content : RENDITION_LAYOUTS.first
        end

        # @param layout [String] the value of rendition:layout. "reflowable" or "pre-paginated"
        def rendition_layout=(layout)
          raise unless RENDITION_LAYOUTS.include? layout

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
        end

        def reflowable?
          self.rendition_layout == 'reflowable'
        end

        def pre_paginated?
          self.rendition_layout == 'pre-paginated'
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
