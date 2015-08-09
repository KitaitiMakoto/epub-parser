module EPUB
  class CFI < Struct.new(:path, :range)
    SPECIAL_CHARS = '^[](),;=' # "5E", "5B", "5D", "28", "29", "2C", "3B", "3D"
    RE_ESCAPED_SPECIAL_CHARS = Regexp.escape(SPECIAL_CHARS)

    class << self
      def escape(string)
        string.gsub(/([#{RE_ESCAPED_SPECIAL_CHARS}])/o, '^\1')
      end

      def unescape(string)
        string.gsub(/\^([#{RE_ESCAPED_SPECIAL_CHARS}])/o, '\1')
      end
    end

    class Path < Struct.new(:step, :local_path)
    end

    class Range < Struct.new(:start, :end)
    end

    class LocalPath < Struct.new(:steps, :redirected_path, :offset)
    end

    class RedirectedPath < Struct.new(:offset, :path)
    end

    class Step < Struct.new(:step, :assertion)
    end

    class IDAssertion < Struct.new(:id, :parameters)
    end

    class TextLocationAssertion < Struct.new(:preceded, :followed, :parameters)
    end

    class CharacterOffset < Struct.new(:offset, :assertion)
    end

    class SpatialOffset < Struct.new(:x, :y, :temporal, :assertion)
      def initialize(x, y, temporal, assertion)
        [x, y].each do |dimension|
          next unless dimension
          raise RangeError, "dimension must be in 0..100 but passed #{dimension}" unless (0.0..100.0).cover?(dimension)
        end

        warn "Assertion is passed to #{__class__} but cannot know how to handle with it: #{assertion}" if assertion

        super
      end

      def x=(x)
        raise RangeError, "dimension must be in 0..100 but passed #{x}" unless (0.0..100.0).cover?(x)

        super
      end

      def y=(y)
        raise RangeError, "dimension must be in 0..100 but passed #{y}" unless (0.0..100.0).cover?(y)

        super
      end

      def assertion=(assertion)
        warn "Assertion is passed to #{__class__} but cannot know how to handle with it: #{assertion}" if assertion

        super
      end
    end
  end
end
