require 'epub'

module EPUB
  class Searcher
    class XHTML
      class Restricted
        class << self
          # @param element [Nokogiri::XML::Element, Nokogiri::XML::Document]
          # @param word [String]
          # @return [Array<Result>]
          def search(element, word)
            new(word).search(element.respond_to?(:root) ? element.root : element)
          end
        end

        # @param word [String]
        def initialize(word)
          @word = word
        end

        # @param element [Nokogiri::XML::Element]
        # @return [Array<Result>]
        def search(element)
          results = []

          elem_index = 0
          text_index = 0
          element.children.each_with_index do |child, elem|
            if child.element?
              child_step = Result::Step.new(:element, elem_index, child.name)
              search(child).each do |sub_result|
                results << Result.new([child_step] + sub_result.parent_steps, sub_result.start_steps, sub_result.end_steps)
              end
              elem_index += 1
            elsif child.text?
              char_index = 0
              text_step = Result::Step.new(:text, text_index)
              while char_index = child.text.index(@word, char_index)
                results << Result.new([text_step], [Result::Step.new(:character, char_index)], [Result::Step.new(:character, char_index + @word.length)])
                char_index += 1
              end
              text_index += 1
            end
          end

          results
        end
      end
    end
  end
end
