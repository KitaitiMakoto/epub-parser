module EPUB
  module Publication
    class Package
      class Metadata
        DC_ELEMS = [:identifiers, :titles, :languages] +
                   [:contributors, :coverages, :creators, :dates, :descriptions, :formats, :publishers,
                    :relations, :rights, :sources, :subjects, :types]
        attr_accessor :package, :unique_identifier, :metas, :links,
                      *(DC_ELEMS.collect {|elem| "dc_#{elem}"})
        DC_ELEMS.each do |elem|
          alias_method elem, "dc_#{elem}"
          alias_method "#{elem}=", "dc_#{elem}="
        end

        def to_hash
          DC_ELEMS.inject({}) do |hsh, elem|
            hsh[elem] = __send__(elem)
            hsh
          end
        end

        def primary_metas
          metas.select {|meta| meta.primary_expression?}
        end

        module Refinable
          PROPERTIES = %w[ alternate-script display-seq file-as group-position identifier-type meta-auth role title-type ]

          attr_accessor :refiners
          PROPERTIES.each do |voc|
            attr_accessor voc.gsub(/-/, '_')
          end

          def initialize
            @refiners = []
          end

          PROPERTIES.each do |voc|
            define_method voc.gsub(/-/, '_') do
              @refiners.select {|refiner| refiner.property == voc}.first
            end
          end
        end

        class Identifier
          include Refinable

          attr_accessor :content, :id

          def to_s
            content
          end
        end

        class Title
          include Refinable

          attr_accessor :content, :id, :lang, :dir

          def to_s
            content
          end
        end

        class DCMES
          include Refinable

          attr_accessor :content, :id, :lang, :dir

          def to_s
            content
          end
        end

        class Meta
          include Refinable

          attr_accessor :property, :refines, :id, :scheme, :content

          def refines?
            ! refines.nil?
          end

          alias subexpression? refines?

          def primary_expression?
            ! subexpression?
          end

          def to_s
            content
          end
        end

        class Link
          include Refinable

          attr_accessor :href, :rel, :id, :refines, :media_type,
                        :iri
        end
      end
    end
  end
end
