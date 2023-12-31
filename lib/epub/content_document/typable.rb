require "set"

module EPUB
  module ContentDocument
    module Typable
      def types
        @types ||= Set.new
      end

      def types=(ts)
        @types = ts.kind_of?(Set) ? ts : Set.new(ts)
      end
    end
  end
end
