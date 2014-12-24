module EPUB
  module Searcher
    class Result
      class << self
        # @example
        #   Result.aggregate_step_intersection([a, b, c], [a, b, d]) # => [[a, b], [c], [d]]
        # @example
        #   Result.aggregate_step_intersection([a, b, c], [a, d, c]) # => [[a], [b, c], [d, c]]
        #   # Note that c here is not included in the first element of returned value.
        # @param steps1 [Array<Step>, Array<Array>]
        # @param steps2 [Array<Step>, Array<Array>]
        # @return [Array<Array<Array>>] Thee arrays:
        #   1. "intersection" of +steps1+ and +steps2+. "intersection" here is not the term of mathmatics
        #   2. remaining steps of +steps1+
        #   3. remaining steps of +steps2+
        def aggregate_step_intersection(steps1, steps2)
          intersection = []
          steps1_remaining = []
          steps2_remaining = []
          broken = false
          steps1.zip steps2 do |step1, step2|
            broken = true unless step1 && step2 && step1 == step2
            if broken
              steps1_remaining << step1 unless step1.nil?
              steps2_remaining << step2 unless step2.nil?
            else
              intersection << step1
            end
          end

          [intersection, steps1_remaining, steps2_remaining]
        end
      end

      attr_reader :parent_steps, :start_steps, :end_steps

      # @param parent_steps [Array<Step>] common steps between start and end
      # @param start_steps [Array<Step>] steps to start from +parent_steps+
      # @param end_steps [Array<Step>] steps to end from +parent_steps+
      def initialize(parent_steps, start_steps, end_steps)
        @parent_steps, @start_steps, @end_steps = parent_steps, start_steps, end_steps
      end

      def to_xpath_and_offset(with_xmlns=false)
        xpath = (@parent_steps + @start_steps).reduce('.') {|path, step|
          case step.type
          when :element
            path + '/%s*[%d]' % [with_xmlns ? 'xhtml:' : nil, step.index + 1]
          when :text
            path + '/text()[%s]' % [step.index + 1]
          else
            path
          end
        }

        [xpath, @start_steps.last.index]
      end

      def to_cfi_s
        [@parent_steps, @start_steps, @end_steps].collect {|steps|
          steps ? steps.collect(&:to_cfi_s).join : nil
        }.compact.join(',')
      end

      def ==(other)
        [@parent_steps + @start_steps.to_a] == [other.parent_steps + other.start_steps.to_a] and
          [@parent_steps + @end_steps.to_a] == [other.parent_steps + other.end_steps.to_a]
      end

      class Step
        attr_reader :type, :index, :info

        def initialize(type, index, info={})
          @type, @index, @info = type, index, info
        end

        def ==(other)
          self.type == other.type and
            self.index == other.index and
            self.info == other.info
        end

        def to_cfi_s
          case type
          when :element
            '/%d%s' % [(index + 1) * 2, id_assertion]
          when :text
            '/%d' % [(index + 1)]
          when :character
            ':%d' % [index]
          when :itemref
            '/%d%s!' % [(index + 1) * 2, id_assertion]
          end
        end

        private

        def id_assertion
          info[:id] ? "[#{info[:id]}]" : nil
        end
      end
    end
  end
end
