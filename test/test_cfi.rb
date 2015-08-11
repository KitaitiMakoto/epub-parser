require_relative 'helper'
require 'epub/cfi'
require 'epub/parser/cfi'

class TestCFI < Test::Unit::TestCase
  def test_escape
    assert_equal '^^', EPUB::CFI.escape('^')
  end

  def test_unescape
    assert_equal '^', EPUB::CFI.unescape('^^')
  end

  def test_compare
    assert_compare epubcfi('/6/4[id]'), '<', epubcfi('/6/5')
    assert_equal epubcfi('/6/4'), epubcfi('/6/4')
    assert_compare epubcfi('/6/4'), '>', epubcfi('/4/6')
    assert_compare epubcfi('/6/4!/4@3:7'), '>', epubcfi('/6/4!/4')
  end

  class TestAssertion < self
    def test_to_s
      assert_equal '[id]', EPUB::CFI::IDAssertion.new('id', {}).to_s
      assert_equal '[id;p=a]', EPUB::CFI::IDAssertion.new('id', {'p' => 'a'}).to_s
    end
  end

  private

  def epubcfi(string)
    EPUB::Parser::CFI.new.parse('epubcfi(' + string + ')')
  end
end
