require 'strscan'
require 'epub/parser/cfi.tab'
require 'epub/cfi'

EPUB::Parser::CFI = EPUB::CFIParser

class EPUB::Parser::CFI
  SPECIAL_CHARS = '^[](),;=' # "5E", "5B", "5D", "28", "29", "2C", "3B", "3D"
  UNICODE_CHARACTER_EXCLUDING_SPECIAL_CHARS_AND_SPACE_AND_DOT_AND_COLON_AND_TILDE_AND_ATMARK_AND_SOLIDUS_AND_EXCLAMATION_MARK_PATTERN = /\u0009|\u000A|\u000D|[\u0022-\u0027]|[\u002A-\u002B]|\u002D|[\u0030-\u0039]|\u003C|[\u003E-\u0040]|[\u0041-\u005A]|\u005C|[\u005F-\u007D]|[\u007F-\uD7FF]|[\uE000-\uFFFD]|[\u10000-\u10FFFF]/ # excluding special chars and space(\u0020) and dot(\u002E) and colon(\u003A) and tilde(\u007E) and atmark(\u0040) and solidus(\u002F) and exclamation mark(\u0021)
  UNICODE_CHARACTER_PATTERN = Regexp.union(UNICODE_CHARACTER_EXCLUDING_SPECIAL_CHARS_AND_SPACE_AND_DOT_AND_COLON_AND_TILDE_AND_ATMARK_AND_SOLIDUS_AND_EXCLAMATION_MARK_PATTERN, Regexp.new(Regexp.escape(SPECIAL_CHARS), / \.:~@!/))

  def parse(string)
    @scanner = StringScanner.new(string, true)
    @q = []
    until @scanner.eos?
      case
      when @scanner.scan(/epubcfi/)
        @q << ['epubcfi', @scanner[0]]
      when @scanner.scan(/[1-9]/)
        @q << [:DIGIT_NON_ZERO, @scanner[0]]
      when @scanner.scan(/0/)
        @q << [:ZERO, @scanner[0]]
      when @scanner.scan(/ /)
        @q << [:SPACE, @scanner[0]]
      when @scanner.scan(/\^/)
        @q << [:CIRCUMFLEX, @scanner[0]]
      when @scanner.scan(/\[/)
        @q << [:OPENING_SQUARE_BRACKET, @scanner[0]]
      when @scanner.scan(/\]/)
        @q << [:CLOSING_SQUARE_BRACKET, @scanner[0]]
      when @scanner.scan(/\(/)
        @q << [:OPENING_PARENTHESIS, @scanner[0]]
      when @scanner.scan(/\)/)
        @q << [:CLOSING_PARENTHESIS, @scanner[0]]
      when @scanner.scan(/,/)
        @q << [:COMMA, @scanner[0]]
      when @scanner.scan(/;/)
        @q << [:SEMICOLON, @scanner[0]]
      when @scanner.scan(/=/)
        @q << [:EQUAL, @scanner[0]]
      when @scanner.scan(/\./)
        @q << [:DOT, @scanner[0]]
      when @scanner.scan(/:/)
        @q << [:COLON, @scanner[0]]
      when @scanner.scan(/~/)
        @q << [:TILDE, @scanner[0]]
      when @scanner.scan(/@/)
        @q << [:ATMARK, @scanner[0]]
      when @scanner.scan(/\//)
        @q << [:SOLIDUS, @scanner[0]]
      when @scanner.scan(/!/)
        @q << [:EXCLAMATION_MARK, @scanner[0]]
      when @scanner.scan(UNICODE_CHARACTER_EXCLUDING_SPECIAL_CHARS_AND_SPACE_AND_DOT_AND_COLON_AND_TILDE_AND_ATMARK_AND_SOLIDUS_AND_EXCLAMATION_MARK_PATTERN)
        @q << [:UNICODE_CHARACTER_EXCLUDING_SPECIAL_CHARS_AND_SPACE_AND_DOT_AND_COLON_AND_TILDE_AND_ATMARK_AND_SOLIDUS_AND_EXCLAMATION_MARK, @scanner[0]]
      else
        raise 'unexpected character'
      end
    end
    @q << [false, false]

    do_parse
  end

  def next_token
    @q.shift
  end
end
