require 'epub/publication'

module EPUB
  module Searcher
    class Publication
      class << self
        def search(package, word)
          new(word).search(package)
        end
      end

      def initialize(word)
        @word = word
      end

      def search(package)
        results = []

        spine_step = Result::Step.new(:element, 2, {:name => 'spine'})
        package.spine.each_itemref.with_index do |itemref, index|
          itemref_step = Result::Step.new(:itemref, index)
          XHTML::Restricted.search(Nokogiri.XML(itemref.item.read), @word).each do |sub_result|
            results << Result.new([spine_step, itemref_step] + sub_result.parent_steps, sub_result.start_steps, sub_result.end_steps)
          end
        end

        results
      end
    end
  end
end
