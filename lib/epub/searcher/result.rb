module EPUB
  class Searcher
    class Result
      attr_reader :steps

      # @param steps [Array<Step>]
      def initialize(steps)
        @steps = steps
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
