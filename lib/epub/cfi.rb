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

    class Path
      include Comparable

      attr_reader :step, :local_path

      def initialize(step, local_path=nil)
        @step, @local_path = step, local_path
      end

      def to_s
        "#{step}#{local_path}"
      end

      def to_fragment
        "epubcfi(#{self})"
      end

      def <=>(other)
        cmp = step <=> other.step
        return cmp unless cmp == 0
        local_path <=> other.local_path
      end

      # @todo FIXME: Don't use #to_s and don't parse it
      def +(local_path)
        Parser::CFI.parse('epubcfi(' + to_s + local_path.to_s + ')')
      end

      def each_step_with_instruction
        yield [step, nil]
        local_path.each_step_with_instruction do |s, instruction|
          yield [s, instruction]
        end
        self
      end

      # @param package [EPUB::Book, EPUB::Publication::Package, EPUB::Book::Features]
      # @todo Consider the case itemref has child elements other than itemref.
      def identify(package)
        if package.kind_of? EPUB::Book::Features
          book = package
          package = book.package
        else
          book = package.book
        end

        # FIXME: Too dirty
        # TODO: Consider non-epub namespaced elements
        raise NotImplementedError unless step.step == 6
        current = package.spine
        return current if local_path.steps.empty?
        raise NotImplementedError unless local_path.steps.length == 1 # FIXME: invalid rather than not implemented
        current = current.itemrefs[local_path.steps.first.step/2 - 1]
        raise NotImplementedError if local_path.offset # FIXME: invalid rather than not implemented
        return current unless local_path.redirected_path
        raise NotImplementedError unless current.item.xhtml? # FIXME: invalid rather than not implemented
        current = current.item.content_document.nokogiri.root

        local_path.redirected_path.path.each_step_with_instruction do |s, instruction|
          if s.step.odd?
            current = s.step == 1 ?
              current.children[0] :
              current.elements[(s.step-1)/2 - 1]
            begin
              return if current.element?
              return current
            end until current.text? || current.element? || current.nil?
          end
          case instruction
          when :indirection
            raise NotImplementedError
          else
            current = current.elements[s.step/2 - 1]
          end
        end
        current
      end
    end

    class Range < ::Range
      attr_reader :parent, :start, :end

      def initialize(parent_path, start_subpath, end_subpath, exclude_end=false)
        @parent, @start, @end = parent_path, start_subpath, end_subpath
        first = @parent + @start
        last = @parent + @end
        super(first, last, exclude_end)
      end

      def to_s
        first.to_fragment + (exclude_end? ? '...' : '..') + last.to_fragment
      end

      def to_fragment
        "epubcfi(#{@parent},#{@start},#{@end})"
      end
    end

    class LocalPath
      include Comparable

      attr_reader :steps, :redirected_path, :offset

      def initialize(steps=[], redirected_path=nil, offset=nil)
        @steps, @redirected_path, @offset = steps, redirected_path, offset
      end

      def to_s
        "#{steps.map(&:to_s).join}#{redirected_path}#{offset}"
      end

      def <=>(other)
        cmp = steps <=> other.steps
        return cmp unless cmp == 0
        cmp = redirected_path <=> other.redirected_path
        return cmp unless cmp == 0
        return -1 if offset.nil? and !other.offset.nil?
        return 1 if !offset.nil? and other.offset.nil?
        offset <=> other.offset
      end

      def each_step_with_instruction
        steps.each do |step|
          yield [step, nil]
        end
        if redirected_path
          redirected_path.each_step_with_instruction do |step, instruction|
            yield [step, instruction]
          end
        end
        self
      end
    end

    class RedirectedPath
      include Comparable

      attr_reader :path, :offset

      def initialize(path, offset=nil)
        @path, @offset = path, offset
      end

      def to_s
        s = '!'
        s << (path ? path.to_s : offset.to_s)
        s
      end

      def <=>(other)
        if offset and offset.kind_of? TemporalSpatialOffset
          if other.offset.kind_of? TemporalSpatialOffset
            # If other has offset attribute, it doesn't have path attribute
            # If other.offset is a character offset, always self is greater than other
            return offset <=> other.offset
          else
            return 1
          end
        end
        if path
          if other.offset.kind_of? TemporalSpatialOffset
            return -1
          elsif other.path
            return path <=> other.path
          else
            return 1
          end
        end
        # self.offset is a CharacterOffset
        if other.offset.kind_of? CharacterOffset
          return offset <=> other.offset
        else
          # redirected path with character offset is lesser than path and other types of offset(character offset)
          return -1
        end
        # no consideration
        nil
      end

      def each_step_with_instruction
        return [self, :indirection] unless path
        first = true
        path.each_step_with_instruction do |step, instruction|
          if first
            yield [step, :indirection]
          else
            yield [step, nil]
          end
        end
        self
      end
    end

    class Step
      include Comparable

      attr_reader :step, :assertion

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
      attr_reader :id, :parameters

      def initialize(id, parameters={})
        @id, @parameters = id, parameters
      end

      def to_s
        s = '['
        s << CFI.escape(id) if id
        parameters.each_pair do |key, values|
          value = values.join(',')
          s << ";#{CFI.escape(key)}=#{CFI.escape(value)}"
        end
        s << ']'
      end
    end

    class TextLocationAssertion
      attr_reader :preceded, :followed, :parameters

      def initialize(preceded=nil, followed=nil, parameters={})
        @preceded, @followed, @parameters = preceded, followed, parameters
      end

      def to_s
        s = '['
        s << CFI.escape(preceded) if preceded
        s << ',' << CFI.escape(followed) if followed
        parameters.each_pair do |key, values|
          value = values.join(',')
          s << ";#{CFI.escape(key)}=#{CFI.escape(value)}"
        end
        s << ']'
      end
    end

    class CharacterOffset
      include Comparable

      attr_reader :offset, :assertion

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

      attr_reader :temporal, :x, :y, :assertion

      def initialize(temporal=nil, x=nil, y=nil, assertion=nil)
        raise RangeError, "dimension must be in 0..100 but passed #{x}" unless (0.0..100.0).cover?(x) if x
        raise RangeError, "dimension must be in 0..100 but passed #{y}" unless (0.0..100.0).cover?(y) if y
        warn "Assertion is passed to #{__class__} but cannot know how to handle with it: #{assertion}" if assertion
        @temporal, @x, @y, @assertion = temporal, x, y, assertion
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
