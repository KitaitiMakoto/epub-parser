require 'epub/publication'

module EPUB
  module Searcher
    class Publication
      class << self
        # @todo Use named argument in the future
        def search(package, word, options={algorithm: :seamless})
          new(word).search(package, options)
        end
      end

      def initialize(word)
        @word = word
      end

      # @todo Use named argument in the future
      def search(package, options={algorithm: :seamless})
        results = []

        spine = package.spine
        spine_step = Result::Step.new(:element, 2, {:name => 'spine', :id => spine.id})
        spine.each_itemref.with_index do |itemref, index|
          itemref_step = Result::Step.new(:itemref, index, {:id => itemref.id})
          XHTML::ALGORITHM[options[:algorithm]].search(Nokogiri.XML(itemref.item.read), @word).each do |sub_result|
            results << Result.new([spine_step, itemref_step] + sub_result.parent_steps, sub_result.start_steps, sub_result.end_steps)
          end
        end

        results
      end
    end
  end
end
