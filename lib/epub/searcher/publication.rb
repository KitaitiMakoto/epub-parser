require 'epub/publication'

module EPUB
  module Searcher
    class Publication
      class << self
        def search_text(package, word, **options)
          new(word).search_text(package, options)
        end
      end

      def initialize(word)
        @word = word
      end

      def search_text(package, algorithm: :seamless)
        results = []

        spine = package.spine
        spine_step = Result::Step.new(:element, 2, {:name => 'spine', :id => spine.id})
        spine.each_itemref.with_index do |itemref, index|
          itemref_step = Result::Step.new(:itemref, index, {:id => itemref.id})
          XHTML::ALGORITHMS[algorithm].search_text(Nokogiri.XML(itemref.item.read), @word).each do |sub_result|
            results << Result.new([spine_step, itemref_step] + sub_result.parent_steps, sub_result.start_steps, sub_result.end_steps)
          end
        end

        results
      end
    end
  end
end
