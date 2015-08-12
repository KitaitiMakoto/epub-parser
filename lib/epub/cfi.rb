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

    class RedirectedPath
      include Comparable

      attr_accessor :path, :offset

      def initialize(path, offset=nil)
        @path, @offset = path, offset
      end

      def <=>(other)
        cmp = path <=> other.path
        return cmp unless cmp == 0
        offset <=> other.offset
      end
    end

    class Step
      include Comparable

      attr_accessor :step, :assertion

      def initialize(step, assertion=nil)
        @step, @assertion = step, assertion
      end

      def to_s
        "/#{step}#{assertion}" # need escape?
      end

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

    class TextLocationAssertion
      attr_accessor :preceded, :followed, :parameters

      def initialize(preceded=nil, followed=nil, parameters={})
        @preceded, @followed, @parameters = preceded, followed, parameters
      end

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

    class CharacterOffset
      include Comparable

      attr_accessor :offset, :assertion

      def initialize(offset, assertion=nil)
        @offset, @assertion = offset, assertion
      end

      def to_s
        ":#{offset}#{assertion}" # need escape?
      end

      def <=>(other)
        offset <=> other.offset
      end
    end

    class TemporalSpatialOffset
      include Comparable

      attr_accessor :temporal
      attr_reader :x, :y, :assertion

      def initialize(temporal=nil, x=nil, y=nil, assertion=nil)
        self.temporal = temporal
        self.x = x
        self.y = y
        self.assertion = assertion
      end

      def x=(x)
        raise RangeError, "dimension must be in 0..100 but passed #{x}" unless (0.0..100.0).cover?(x) if x

        @x = x
      end

      def y=(y)
        raise RangeError, "dimension must be in 0..100 but passed #{y}" unless (0.0..100.0).cover?(y) if y

        @y = y
      end

      def assertion=(assertion)
        warn "Assertion is passed to #{__class__} but cannot know how to handle with it: #{assertion}" if assertion

        @assertion = assertion
      end

      def to_s
        s = ''
        s << "~#{temporal}" if temporal
        s << "@#{x}:#{y}" if x or y
        s
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
