module EPUB
  class Searcher
    class Result
      attr_reader :steps

      # @param steps [Array<Step>]
      def initialize(steps)
        @steps = steps
      end

      def to_xpath_and_offset(with_xmlns=false)
        xpath = @steps.reduce('') {|path, step|
          case step.type
          when :element
            path + '/%s*[%d]' % [with_xmlns ? 'xhtml:' : nil, step.index + 1]
          when :text
            path + '/text()[%s]' % [step.index + 1]
          else
            path
          end
        }

        [xpath, @steps.last.index]
      end

      def to_cfi
        @steps.reduce('') {|path, step|
          case step.type
          when :element
            path + '/%d' % [(step.index + 1) * 2]
          when :text
            path + ':'
          when :character
            path + step.index.to_s
          else
            path
          end
        }
      end

      protected

      def ==(other)
        self.steps == other.steps
      end

      class Step
        attr_reader :type, :index, :name

        def initialize(type, index, name=nil)
          @type, @index, @name = type, index, name
        end

        protected

        def ==(other)
          self.type == other.type and
            self.index == other.index and
            self.name == other.name
        end
      end

      class Formatter
      end
    end
  end
end
