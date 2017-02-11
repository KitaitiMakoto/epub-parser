module EPUB
  module CFI
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

    class Location
      include Comparable

      attr_reader :paths

      def initialize(paths=[])
        @paths = paths
      end

      def initialize_copy(original)
        @paths = original.paths.collect(&:dup)
      end

      def type
        @paths.last.type
      end

      def <=>(other)
        index = 0
        other_paths = other.paths
        cmp = nil
        paths.each do |path|
          other_path = other_paths[index]
          return 1 unless other_path
          cmp = path <=> other_path
          break unless cmp == 0
          index += 1
        end

        unless cmp == 0
          if cmp == 1 and paths[index].offset and other_paths[index + 1]
            return nil
          else
            return cmp
          end
        end

        return nil if paths.last.offset && other_paths[index]

        return -1 if other_paths[index]

        0
      end

      def to_s
        paths.join('!')
      end

      def to_fragment
       "epubcfi(#{self})"
      end

      def join(*other_paths)
        new_paths = paths.dup
        other_paths.each do |path|
          new_paths << path
        end
        self.class.new(new_paths)
      end
    end

    class Path
      attr_reader :steps, :offset

      def initialize(steps=[], offset=nil)
        @steps, @offset = steps, offset
      end

      def initialize_copy(original)
        @steps = original.steps.collect(&:dup)
        @offset = original.offset.dup if original.offset
      end

      def to_s
        @string_cache ||= (steps.join + offset.to_s)
      end

      def to_fragment
        @fragment_cache ||= "epubcfi(#{self})"
      end

      def <=>(other)
        other_steps = other.steps
        index = 0
        steps.each do |step|
          other_step = other_steps[index]
          return 1 unless other_step
          cmp = step <=> other_step
          return cmp unless cmp == 0
          index += 1
        end

        return -1 if other_steps[index]

        other_offset = other.offset
        if offset
          if other_offset
            offset <=> other_offset
          else
            1
          end
        else
          if other_offset
            -1
          else
            0
          end
        end
      end

      def each_step_with_instruction
        yield [step, nil]
        local_path.each_step_with_instruction do |s, instruction|
          yield [s, instruction]
        end
        self
      end
    end

    class Range < ::Range
      attr_accessor :parent, :start, :end

      # @todo consider the case subpaths are redirected path
      # @todo FIXME: too dirty
      class << self
        def from_parent_and_start_and_end(parent_path, start_subpath, end_subpath)
          start_str = start_subpath.join
          end_str = end_subpath.join

          first_paths = parent_path.collect(&:dup)
          if start_subpath
            offset_of_first = start_subpath.last.offset
            offset_of_first = offset_of_first.dup if offset_of_first
            last_of_first_paths = first_paths.pop
            first_paths << last_of_first_paths
            last_of_first_paths.steps.concat start_subpath.shift.steps
            first_paths.concat start_subpath
            first_paths.last.instance_variable_set :@offset, offset_of_first
          end
          offset_of_last = end_subpath.last.offset
          offset_of_last = offset_of_last.dup if offset_of_last
          last_paths = parent_path.collect(&:dup)
          last_of_last_paths = last_paths.pop
          last_paths << last_of_last_paths
          last_of_last_paths.steps.concat end_subpath.shift.steps
          last_paths.concat end_subpath
          last_paths.last.instance_variable_set :@offset, offset_of_last

          first = CFI::Location.new(first_paths)
          last = CFI::Location.new(last_paths)

          new_range = new(first, last)

          new_range.parent = Location.new(parent_path)
          new_range.start = start_str
          new_range.end = end_str

          new_range
        end
      end

      def to_s
        @string_cache ||= (first.to_fragment + (exclude_end? ? '...' : '..') + last.to_fragment)
      end

      def to_fragment
        @fragment_cache ||= "epubcfi(#{@parent},#{@start},#{@end})"
      end
    end

    class Step
      attr_reader :value, :assertion
      alias step value

      def initialize(value, assertion=nil)
        @value, @assertion = value, assertion
        @string_cache = nil
      end

      def initialize_copy(original)
        @value = original.value
        @assertion = original.assertion.dup if original.assertion
      end

      def to_s
        @string_cache ||= "/#{value}#{assertion}" # need escape?
      end

      def <=>(other)
        value <=> other.value
      end

      def element?
        value.even?
      end

      def character_data?
        value.odd?
      end
    end

    class IDAssertion
      attr_reader :id, :parameters

      def initialize(id, parameters={})
        @id, @parameters = id, parameters
        @string_cache = nil
      end

      def to_s
        return @string_cache if @string_cache
        string_cache = '['
        string_cache << CFI.escape(id) if id
        parameters.each_pair do |key, values|
          value = values.join(',')
          string_cache << ";#{CFI.escape(key)}=#{CFI.escape(value)}"
        end
        string_cache << ']'
        @string_cache = string_cache
      end
    end

    class TextLocationAssertion
      attr_reader :preceded, :followed, :parameters

      def initialize(preceded=nil, followed=nil, parameters={})
        @preceded, @followed, @parameters = preceded, followed, parameters
        @string_cache = nil
      end

      def to_s
        return @string_cache if @string_cache
        string_cache = '['
        string_cache << CFI.escape(preceded) if preceded
        string_cache << ',' << CFI.escape(followed) if followed
        parameters.each_pair do |key, values|
          value = values.join(',')
          string_cache << ";#{CFI.escape(key)}=#{CFI.escape(value)}"
        end
        string_cache << ']'
        @string_cache = string_cache
      end
    end

    class CharacterOffset
      attr_reader :value, :assertion
      alias offset value

      def initialize(value, assertion=nil)
        @value, @assertion = value, assertion
        @string_cache = nil
      end

      def to_s
        @string_cache ||= ":#{value}#{assertion}" # need escape?
      end

      def <=>(other)
        value <=> other.value
      end
    end

    class TemporalSpatialOffset
      attr_reader :temporal, :x, :y, :assertion

      def initialize(temporal=nil, x=nil, y=nil, assertion=nil)
        raise RangeError, "dimension must be in 0..100 but passed #{x}" unless (0.0..100.0).cover?(x) if x
        raise RangeError, "dimension must be in 0..100 but passed #{y}" unless (0.0..100.0).cover?(y) if y
        warn "Assertion is passed to #{__class__} but cannot know how to handle with it: #{assertion}" if assertion
        @temporal, @x, @y, @assertion = temporal, x, y, assertion
        @string_cache = nil
      end

      def to_s
        return @string_cache if @string_cache
        string_cache = ''
        string_cache << "~#{temporal}" if temporal
        string_cache << "@#{x}:#{y}" if x or y
        @string_cache = string_cache
      end

      # @note should split the class to spatial offset and temporal-spatial offset?
      def <=>(other)
        return -1 if temporal.nil? and other.temporal
        return 1 if temporal and other.temporal.nil?
        cmp = temporal <=> other.temporal
        return cmp unless cmp == 0
        return -1 if y.nil? and other.y
        return 1 if y and other.y.nil?
        cmp = y <=> other.y
        return cmp unless cmp == 0
        return -1 if x.nil? and other.x
        return 1 if x and other.x.nil?
        cmp = x <=> other.x
      end
    end
  end
end
