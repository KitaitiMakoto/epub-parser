require 'set'

module EPUB
  class Metadata
    include Inspector::PublicationModel

    DC_ELEMS = [:identifiers, :titles, :languages] +
               [:contributors, :coverages, :creators, :dates, :descriptions, :formats, :publishers,
                :relations, :rights, :sources, :subjects, :types]
    # Used for CFI
    attr_reader :children
    attr_accessor :package, :unique_identifier, :metas, :links,
                  *(DC_ELEMS.collect {|elem| "dc_#{elem}"})
    DC_ELEMS.each do |elem|
      alias_method elem, "dc_#{elem}"
      alias_method "#{elem}=", "dc_#{elem}="
    end

    def initialize
      (DC_ELEMS + [:metas, :links]).each do |elem|
        __send__ "#{elem}=", []
      end
      @children = []
    end

    def release_identifier
      "#{unique_identifier}@#{modified}"
    end
    alias package_identifier release_identifier

    def title
      return extended_title unless extended_title.empty?
      compositted = titles.select {|title| title.display_seq}.sort.join("\n")
      return compositted unless compositted.empty?
      return main_title unless main_title.empty?
      titles.sort.join("\n")
    end

    %w[main short collection edition extended].each do |type|
      define_method "#{type}_title" do
        titles.select {|title| title.title_type.to_s == type}.sort.join(' ')
      end
    end

    def subtitle
      titles.select {|title| title.title_type.to_s == 'subtitle'}.sort.join(' ')
    end

    def description
      descriptions.join(' ')
    end

    def date
      dates.first
    end

    def language
      languages.first
    end

    def modified
      metas.find {|meta|
        meta.property == 'dcterms:modified' &&
          meta.refiners.empty?
      }
    end

    def to_h
      DC_ELEMS.inject({}) do |hsh, elem|
        hsh[elem] = __send__(elem)
        hsh
      end
    end

    def primary_metas
      metas.select {|meta| meta.primary_expression?}
    end

    module Refinee
      PROPERTIES = %w[alternate-script display-seq file-as group-position identifier-type meta-auth role title-type]

      attr_writer :refiners

      def refiners
        @refiners ||= Set.new
      end

      PROPERTIES.each do |voc|
        met = voc.gsub(/-/, '_')
        attr_writer met
        define_method met do
          refiners.find {|refiner| refiner.property == voc}
        end
      end
    end

    class DCMES
      include Refinee

      attr_accessor :content, :id, :lang, :dir

      def to_s
        content.to_s
      end
    end

    class Identifier < DCMES
      # @note This is ad-hoc
      # @todo Define and include OPF module for opf:scheme attribute
      # @todo Define general way to handle with identifier-type refiners
      attr_accessor :scheme

      # @note This is ad-hoc
      # @todo Define and include OPF module for opf:scheme attribute
      # @todo Define general way to handle with identifier-type refiners
      def isbn?
        scheme == 'ISBN' or
        content.to_s.downcase.start_with? 'urn:isbn' or
        refiners.any? {|refiner|
          refiner.property == 'identifier-type' and
          refiner.scheme == 'onix:codelist5' and
          %w[02 15].include? refiner.content
        }
      end
    end

    class Title < DCMES
      include Comparable

      def <=>(other)
        return 1 if other.display_seq.nil?
        return -1 if display_seq.nil?
        display_seq.to_s.to_i <=> other.display_seq.to_s.to_i
      end
    end

    class Meta
      include Refinee

      attr_accessor :property, :id, :scheme, :content, :name, :meta_content
      attr_reader :refines

      def refines=(refinee)
        refinee.refiners << self
        @refines = refinee
      end

      def refines?
        ! refines.nil?
      end
      alias subexpression? refines?

      def primary_expression?
        ! subexpression?
      end

      def inspect
        ivs = instance_variables.map {|iv|
          [iv, instance_variable_get(iv).inspect].join('=')
        }.join(' ')
        '<#%s:%#0x %s>' % [self.class, __id__, ivs]
      end

      def to_s
        content.to_s
      end
    end

    class Link
      include Refinee

      attr_accessor :href, :rel, :id, :media_type
      attr_reader :refines

      def refines=(refinee)
        refinee.refiners << self
        @refines = refinee
      end
    end

    class UnsupportedModel
      attr_accessor :raw_element

      def initialize(raw_element)
        @raw_element = raw_element
      end
    end
  end
end
