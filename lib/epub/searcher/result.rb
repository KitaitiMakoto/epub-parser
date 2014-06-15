module EPUB
  class Searcher
    class Result
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
          steps.reduce('') {|path, step|
            case step.type
            when :element
              path + '/%d' % [(step.index + 1) * 2]
            when :text
              path + '/%d' % [(step.index + 1)]
            when :character
              path + ':%d' % [step.index]
            else
              path
            end
          }
        }.join(',')
      end

      def ==(other)
        [@parent_steps + @start_steps] == [other.parent_steps + other.start_steps] and
          [@parent_steps + @end_steps] == [other.parent_steps + other.end_steps]
      end

      class Step
        attr_reader :type, :index, :name

        def initialize(type, index, name=nil)
          @type, @index, @name = type, index, name
        end

        def ==(other)
          self.type == other.type and
            self.index == other.index and
            self.name == other.name
        end
      end
    end
  end
end
