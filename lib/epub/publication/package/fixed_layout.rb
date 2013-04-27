module EPUB
  module Publication
    module FixedLayout
      class << self
        def included(package_class)
          [
           [Package::Metadata, self::MetadataMixin],
           [Package::Spine::Itemref, self::ItemrefMixin],
           [Package::Manifest::Item, self::ItemMixin],
           [ContentDocument, self::ContentDocumentMixin],
          ].each do |(base, mixin)|
            base.module_eval do
              include mixin
            end
          end
        end
      end

      module MetadataMixin
        INITIAL_RENDITION_LAYOUT = 'reflowable'
        def rendition_layout
          layout = metas.find {|meta| meta.property == 'rendition:layout'}
          layout ? layout.content : INITIAL_RENDITION_LAYOUT
        end

        def reflowable?
          rendition_layout == 'reflowable'
        end

        def pre_paginated?
          rendition_layout == 'pre-paginated'
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
