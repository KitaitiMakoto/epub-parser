# coding: utf-8
require_relative 'helper'
require 'epub/parser/cfi'

class TestParserCFI < Test::Unit::TestCase
  def setup
    @parser = EPUB::Parser::CFI.new(debug: true)
  end

  # from http://www.idpf.org/epub/linking/cfi/epub-cfi.html
  data([
    'epubcfi(/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]])',
    'epubcfi(/6/4!/4/10/2/1:3[Ф-"spa ce"-99%-aa^[bb^]^^])',
    'epubcfi(/6/4!/4/10/2/1:3[Ф-"spa%20ce"-99%25-aa^[bb^]^^])',
    'epubcfi(/6/4!/4/10/2/1:3[%d0%a4-"spa%20ce"-99%25-aa^[bb^]^^])',
    'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[yyy])',
    'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/1:3[xx,y])',
    'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[,y])',
    'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[;s=b])',
    'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[yyy;s=b])',
    'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[^(;s=b])',
    'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2[;s=b])',
    'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/3:10)',
    'epubcfi(/6/4[chap01ref]!/4[body01]/16[svgimg])',
    'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/1:0)',
    'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:0)',
    'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3)',
    'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05],/2/1:1,/3:4)',
    'epubcfi(/6,:1,:3)',
    'epubcfi(/6/4[chap01ref]!/4[body01]/10[mov01]~23.5@5.75:97.6)'
  ].reduce({}) {|data, cfi|
    data[cfi] = cfi
    data
  })
  def test_raise_no_error_on_parsing_valid_cfi(cfi)
    assert_nothing_raised do
      @parser.parse(cfi)
    end
  end

  data([
    '/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[(;s=b]',
    '/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[);s=b]'
  ].reduce({}) {|data, cfi|
    data[cfi] = cfi
    data
  })
  def test_raise_error_on_parsing_invalid_cfi(cfi)
    assert_raise Racc::ParseError do
      EPUB::CFI(cfi)
    end
  end
end
