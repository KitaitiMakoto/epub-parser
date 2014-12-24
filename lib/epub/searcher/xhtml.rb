require 'epub'
require 'epub/parser/utils'

module EPUB
  module Searcher
    class XHTML
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

      class Restricted < self
        # @param element [Nokogiri::XML::Element]
        # @return [Array<Result>]
        def search(element)
          results = []

          elem_index = 0
          element.children.each do |child|
            if child.element?
              child_step = Result::Step.new(:element, elem_index, {:name => child.name, :id => Parser::Utils.extract_attribute(child, 'id')})
              if child.name == 'img'
                if Parser::Utils.extract_attribute(child, 'alt').index(@word)
                  results << Result.new([child_step], nil, nil)
                end
              else
                search(child).each do |sub_result|
                  results << Result.new([child_step] + sub_result.parent_steps, sub_result.start_steps, sub_result.end_steps)
                end
              end
              elem_index += 1
            elsif child.text?
              text_index = elem_index
              char_index = 0
              text_step = Result::Step.new(:text, text_index)
              while char_index = child.text.index(@word, char_index)
                results << Result.new([text_step], [Result::Step.new(:character, char_index)], [Result::Step.new(:character, char_index + @word.length)])
                char_index += 1
              end
            end
          end

          results
        end
      end

      class Seamless < self
        def search(element)
          indices, content = build_indices(element)
          visit(indices, content)
        end

        def build_indices(element)
          indices = {}
          content = ''

          elem_index = 0
          element.children.each do |child|
            if child.element?
              child_step = Result::Step.new(:element, elem_index, {:name => child.name, :id => Parser::Utils.extract_attribute(child, 'id')})
              elem_index += 1
              if child.name == 'img'
                alt = Parser::Utils.extract_attribute(child, 'alt')
                next if alt.nil? || alt.empty?
                indices[content.length] = [child_step]
                content << alt
              else
                # TODO: Consider block level elements
                content_length = content.length
                sub_indices, sub_content = build_indices(child)
                sub_indices.each_pair do |sub_pos, child_steps|
                  indices[content_length + sub_pos] = [child_step] + child_steps
                end
                content << sub_content
              end
            elsif child.text? || child.cdata?
              text_index = elem_index
              text_step = Result::Step.new(:text, text_index)
              indices[content.length] = [text_step]
              content << child.content
            end
          end

          [indices, content]
        end

        private

        def visit(indices, content)
          results = []
          offsets = indices.keys
          i = 0
          while i = content.index(@word, i)
            offset = find_offset(offsets, i)
            start_steps = indices[offset]
            last_step = start_steps.last
            if last_step.info[:name] == 'img'
              parent_steps = start_steps
              start_steps = end_steps = nil
            else
              start_char_step = Result::Step.new(:character, i - offset)
              end_offset = find_offset(offsets, i + @word.length, true)
              end_steps = indices[end_offset]
              end_char_step = Result::Step.new(:character, i + @word.length - end_offset)
              parent_steps, start_steps, end_steps = Result.aggregate_step_intersection(start_steps, end_steps)
              start_steps << start_char_step
              end_steps << end_char_step
            end
            results << Result.new(parent_steps, start_steps, end_steps)
            i += 1
          end

          results
        end

        # Find max offset greater than or equal to index
        # @param offsets [Array<Integer>] keys of indices
        # @param index [Integer] position of search word in content string
        # @todo: more efficient algorithm
        def find_offset(offsets, index, for_end_position=false)
          comparison_operator = for_end_position ? :< : :<=
          l = offsets.length
          offset_index = (0..l).bsearch {|i|
            o = offsets[l - i]
            next false unless o
            o.send(comparison_operator, index)
          }
          offsets[l - offset_index]
        end
      end
    end
  end
end
