module EPUB
  class CFI < Struct.new(:path, :range)
    include Comparable

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

    # @todo consider range
    def <=>(other)
      path <=> other.path
    end

    class Path < Struct.new(:step, :local_path)
      include Comparable

      def <=>(other)
        cmp = step <=> other.step
        return cmp unless cmp == 0
        local_path <=> other.local_path
      end
    end

    class Range < Struct.new(:start, :end)
    end

    class LocalPath < Struct.new(:steps, :redirected_path, :offset)
      include Comparable

      def <=>(other)
        cmp = steps <=> other.steps
        return cmp unless cmp == 0
        cmp = redirected_path <=> other.redirected_path
        return cmp unless cmp == 0
        return -1 if offset.nil? and !other.offset.nil?
        return 1 if !offset.nil? and other.offset.nil?
        offset <=> other.offset
      end
    end

    class RedirectedPath < Struct.new(:path, :offset)
      include Comparable

      def <=>(other)
        cmp = path <=> other.path
        return cmp unless cmp == 0
        offset <=> other.offset
      end
    end

    class Step < Struct.new(:step, :assertion)
      include Comparable

      def <=>(other)
        step <=> other.step
      end
    end

    class IDAssertion
      attr_accessor :id, :parameters

      def initialize(id, parameters={})
        @id, @parameters = id, parameters
      end

      def to_s
        s = "[#{CFI.escape(id)}"
        parameters.each_pair do |key, value|
          s << ";#{CFI.escape(key)}=#{CFI.escape(value)}"
        end
        s << ']'
      end
    end

    class TextLocationAssertion < Struct.new(:preceded, :followed, :parameters)
      def to_s
        s = '['
        s << CFI.escape(preceded) if preceded
        s << ',' << CFI.escape(followed) if followed
        parameters.each_pair do |key, value|
          s << ";#{CFI.escape(key)}=#{CFI.escape(value)}"
        end
        s << ']'
      end
    end

    class CharacterOffset < Struct.new(:offset, :assertion)
      include Comparable

      def to_s
        s = ":#{offset}" # need escape?
        s << assertion.to_s if assertion
        s
      end

      def <=>(other)
        offset <=> other.offset
      end
    end

    class SpatialOffset < Struct.new(:x, :y, :temporal, :assertion)
      include Comparable

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

      # @note should split the class to spatial offset and temporal-spatial offset?
      def <=>(other)
        return -1 if temporal.nil? and !other.temporal.nil?
        return 1 if !temporal.nil? and other.temporal.nil?
        cmp = temporal <=> other.temporal
        return cmp unless cmp == 0
        return -1 if y.nil? and !other.y.nil?
        return 1 if !y.nil? and other.y.nil?
        cmp = y <=> other.y
        return cmp unless cmp == 0
        return -1 if x.nil? and !other.x.nil?
        return 1 if !x.nil? and other.x.nil?
        cmp = x <=> other.x
      end
    end
  end
end
