# coding: utf-8
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

  class TestPath < self
    data([
      '/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]]',
      '/6/4!/4/10/2/1:3[Ф-"spa ce"-99%-aa^[bb^]^^]',
      '/6/4!/4/10/2/1:3[Ф-"spa%20ce"-99%25-aa^[bb^]^^]',
      '/6/4!/4/10/2/1:3[%d0%a4-"spa%20ce"-99%25-aa^[bb^]^^]',
      '/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[yyy]',
      '/6/4[chap01ref]!/4[body01]/10[para05]/1:3[xx,y]',
      '/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[,y]',
      '/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[;s=b]',
      '/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[yyy;s=b]',
      '/6/4[chap01ref]!/4[body01]/10[para05]/2[;s=b]',
      '/6/4[chap01ref]!/4[body01]/10[para05]/3:10',
      '/6/4[chap01ref]!/4[body01]/16[svgimg]',
      '/6/4[chap01ref]!/4[body01]/10[para05]/1:0',
      '/6/4[chap01ref]!/4[body01]/10[para05]/2/1:0',
      '/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3',
    ].reduce({}) {|data, cfi|
      data[cfi] = cfi
      data
    })
    def test_to_s(cfi)
      assert_equal cfi, epubcfi(cfi).to_s
    end

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
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2[;s=b])',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/3:10)',
      'epubcfi(/6/4[chap01ref]!/4[body01]/16[svgimg])',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/1:0)',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:0)',
      'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3)',
    ].reduce({}) {|data, cfi|
      data[cfi] = cfi
      data
    })
    def test_to_fragment(cfi)
      assert_equal cfi, EPUB::Parser::CFI.parse(cfi).to_fragment
    end

    def test_compare
      assert_compare epubcfi('/6/4[id]'), '<', epubcfi('/6/5')
      assert_equal epubcfi('/6/4'), epubcfi('/6/4')
      assert_compare epubcfi('/6/4'), '>', epubcfi('/4/6')
      assert_compare epubcfi('/6/4!/4@3:7'), '>', epubcfi('/6/4!/4')
      assert_compare epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[yyy]'),
        '>',
        epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]/1:3[xx,y]')
      assert_nil epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]/3:10') <=>
        epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]/3!:10')
      assert_compare epubcfi('/6/4'), '>', epubcfi('/6')
    end
  end

  class TestRange < self
    def test_attributes
      parent = epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]')
      first = epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]/2/1:1')
      last = epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]/3:4')
      range = epubcfi('/6/4[chap01ref]!/4[body01]/10[para05],/2/1:1,/3:4')
      assert_equal parent, range.parent
      assert_equal first, range.first
      assert_equal last, range.last
    end

    def test_to_s
      assert_equal 'epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:1)..epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/3:4)', epubcfi('/6/4[chap01ref]!/4[body01]/10[para05],/2/1:1,/3:4').to_s
    end

    def test_to_fragment
      cfi = '/6/4[chap01ref]!/4[body01]/10[para05],/2/1:1,/3:4'
      assert_equal 'epubcfi(' + cfi + ')', epubcfi('/6/4[chap01ref]!/4[body01]/10[para05],/2/1:1,/3:4').to_fragment
    end

    def test_cover
      assert_true epubcfi('/6/4[chap01ref]!/4[body01]/10[para05],/2/1:1,/3:4').cover? epubcfi('/6/4[chap01ref]!/4[body01]/10[para05]/2/2')
    end
  end

  class TestLocalPath < self
    def setup
      @complex1 = EPUB::CFI::LocalPath.new(
        [EPUB::CFI::Step.new(14, EPUB::CFI::IDAssertion.new('chap05ref'))],
        EPUB::CFI::RedirectedPath.new(
          EPUB::CFI::Path.new(
            EPUB::CFI::Step.new(4, EPUB::CFI::IDAssertion.new('body01')))))
      @complex2 = EPUB::CFI::LocalPath.new(
        [EPUB::CFI::Step.new(4, EPUB::CFI::IDAssertion.new('body01')),
         EPUB::CFI::Step.new(10, EPUB::CFI::IDAssertion.new('para05')),
         EPUB::CFI::Step.new(2),
         EPUB::CFI::Step.new(1)],
        nil,
        EPUB::CFI::CharacterOffset.new(3, EPUB::CFI::TextLocationAssertion.new('yyy')))
      @complex1_without_assertions = EPUB::CFI::LocalPath.new(
        [EPUB::CFI::Step.new(14)],
        EPUB::CFI::RedirectedPath.new(
          EPUB::CFI::Path.new(
            EPUB::CFI::Step.new(4))))
      @complex2_without_assertions = EPUB::CFI::LocalPath.new(
        [EPUB::CFI::Step.new(4),
         EPUB::CFI::Step.new(10),
         EPUB::CFI::Step.new(2),
         EPUB::CFI::Step.new(1)],
        nil,
        EPUB::CFI::CharacterOffset.new(3, EPUB::CFI::TextLocationAssertion.new('yyy')))
      @complex1_without_steps = EPUB::CFI::LocalPath.new(
        [],
        EPUB::CFI::RedirectedPath.new(
          EPUB::CFI::Path.new(
            EPUB::CFI::Step.new(4, EPUB::CFI::IDAssertion.new('body01')))))
    end

    def test_to_s
      assert_equal '', EPUB::CFI::LocalPath.new([], nil, nil).to_s

      assert_equal '/6', EPUB::CFI::LocalPath.new([EPUB::CFI::Step.new(6)], nil, nil).to_s

      assert_equal '!5', EPUB::CFI::LocalPath.new([], EPUB::CFI::RedirectedPath.new(5)).to_s
      assert_equal '!:13', EPUB::CFI::LocalPath.new([], EPUB::CFI::RedirectedPath.new(nil, EPUB::CFI::CharacterOffset.new(13))).to_s

      assert_equal '~44', EPUB::CFI::LocalPath.new([], nil, EPUB::CFI::TemporalSpatialOffset.new(44)).to_s

      assert_equal '/14[chap05ref]!/4[body01]', @complex1.to_s
      assert_equal '/4[body01]/10[para05]/2/1:3[yyy]', @complex2.to_s
    end

    def test_compare
      assert_equal @complex1, @complex1_without_assertions
      assert_equal @complex2, @complex2_without_assertions
      assert_compare @complex1, '>', @complex1_without_steps
    end
  end

  class TestRedirectedPath < self
    def test_to_s
      assert_equal '!4', EPUB::CFI::RedirectedPath.new(EPUB::CFI::Path.new(4)).to_s
      assert_equal '!:5', EPUB::CFI::RedirectedPath.new(nil, EPUB::CFI::CharacterOffset.new(5)).to_s
    end

    def test_compare
      assert_equal EPUB::CFI::RedirectedPath.new(EPUB::CFI::Path.new(4)), EPUB::CFI::RedirectedPath.new(EPUB::CFI::Path.new(4))
      assert_compare EPUB::CFI::RedirectedPath.new(EPUB::CFI::Path.new(4)), '<', EPUB::CFI::RedirectedPath.new(EPUB::CFI::Path.new(8))

      assert_equal EPUB::CFI::RedirectedPath.new(nil, EPUB::CFI::CharacterOffset.new(3)), EPUB::CFI::RedirectedPath.new(nil, EPUB::CFI::CharacterOffset.new(3, EPUB::CFI::TextLocationAssertion.new('yyy')))
      assert_compare EPUB::CFI::RedirectedPath.new(nil, EPUB::CFI::CharacterOffset.new(3)), '<', EPUB::CFI::RedirectedPath.new(nil, EPUB::CFI::CharacterOffset.new(7))

      assert_compare EPUB::CFI::RedirectedPath.new(EPUB::CFI::Path.new(4)), '>', EPUB::CFI::RedirectedPath.new(nil, EPUB::CFI::CharacterOffset.new(6))
      assert_compare EPUB::CFI::RedirectedPath.new(EPUB::CFI::Path.new(4)), '<', EPUB::CFI::RedirectedPath.new(nil, EPUB::CFI::TemporalSpatialOffset.new(2.32))
      assert_compare EPUB::CFI::RedirectedPath.new(nil, EPUB::CFI::CharacterOffset.new(3)), '<', EPUB::CFI::RedirectedPath.new(nil, EPUB::CFI::TemporalSpatialOffset.new(nil, 0, 0))
    end
  end

  class TestStep < self
    def test_to_s
      assert_equal '/6', EPUB::CFI::Step.new(6).to_s
      assert_equal '/4[id]', EPUB::CFI::Step.new(4, EPUB::CFI::IDAssertion.new('id')).to_s
    end

    def test_compare
      assert_equal EPUB::CFI::Step.new(6), EPUB::CFI::Step.new(6, 'assertion')
      assert_compare EPUB::CFI::Step.new(6), '<', EPUB::CFI::Step.new(7)
    end
  end

  class TestIDAssertion < self
    def test_to_s
      assert_equal '[id]', EPUB::CFI::IDAssertion.new('id').to_s
      assert_equal '[id;p=a]', EPUB::CFI::IDAssertion.new('id', {'p' => ['a']}).to_s
    end
  end

  class TestTextLocationAssertion < self
    def test_to_s
      assert_equal '[yyy]', EPUB::CFI::TextLocationAssertion.new('yyy').to_s
      assert_equal '[xx,y]', EPUB::CFI::TextLocationAssertion.new('xx', 'y').to_s
      assert_equal '[,y]', EPUB::CFI::TextLocationAssertion.new(nil, 'y').to_s
      assert_equal '[;s=b]', EPUB::CFI::TextLocationAssertion.new(nil, nil, {'s' => ['b']}).to_s
      assert_equal '[yyy;s=b]', EPUB::CFI::TextLocationAssertion.new('yyy', nil, {'s' => ['b']}).to_s
    end
  end

  class TestCharacterOffset < self
    def test_to_s
      assert_equal ':1', EPUB::CFI::CharacterOffset.new(1).to_s
      assert_equal ':2[yyy]', EPUB::CFI::CharacterOffset.new(2, EPUB::CFI::TextLocationAssertion.new('yyy')).to_s
    end

    def test_compare
      assert_equal EPUB::CFI::CharacterOffset.new(3), EPUB::CFI::CharacterOffset.new(3, EPUB::CFI::TextLocationAssertion.new('yyy'))
      assert_compare EPUB::CFI::CharacterOffset.new(4), '<', EPUB::CFI::CharacterOffset.new(5)
      assert_compare EPUB::CFI::CharacterOffset.new(4, EPUB::CFI::TextLocationAssertion.new(nil, 'xx')), '>', EPUB::CFI::CharacterOffset.new(2)
    end

    class TestSpatialOffset < self
      def test_to_s
        assert_equal '@0.5:30.2', EPUB::CFI::TemporalSpatialOffset.new(nil, 0.5, 30.2).to_s
        assert_equal '@0:100', EPUB::CFI::TemporalSpatialOffset.new(nil, 0, 100).to_s
        assert_equal '@50:50.0', EPUB::CFI::TemporalSpatialOffset.new(nil, 50, 50.0).to_s
      end

      def test_compare
        assert_equal EPUB::CFI::TemporalSpatialOffset.new(nil, 30, 40), EPUB::CFI::TemporalSpatialOffset.new(nil, 30, 40)
        assert_compare EPUB::CFI::TemporalSpatialOffset.new(nil, 30, 40), '>', EPUB::CFI::TemporalSpatialOffset.new(nil, 40, 30)
      end
    end

    class TestTemporalOffset < self
      def test_to_s
        assert_equal '~23.5', EPUB::CFI::TemporalSpatialOffset.new(23.5).to_s
      end

      def test_compare
        assert_equal EPUB::CFI::TemporalSpatialOffset.new(23.5), EPUB::CFI::TemporalSpatialOffset.new(23.5)
        assert_compare EPUB::CFI::TemporalSpatialOffset.new(23), '<', EPUB::CFI::TemporalSpatialOffset.new(23.5)
      end
    end

    class TestTemporalSpatialOffset < self
      def test_to_s
        assert_equal '~23.5@50:30.0', EPUB::CFI::TemporalSpatialOffset.new(23.5, 50, 30.0).to_s
      end

      def test_compare
        assert_equal EPUB::CFI::TemporalSpatialOffset.new(23.5, 30, 40), EPUB::CFI::TemporalSpatialOffset.new(23.5, 30, 40.0)
        assert_compare EPUB::CFI::TemporalSpatialOffset.new(23.5, 30, 40), '>', EPUB::CFI::TemporalSpatialOffset.new(23.5)
        assert_compare EPUB::CFI::TemporalSpatialOffset.new(nil, 30, 40), '<', EPUB::CFI::TemporalSpatialOffset.new(23.5, 30, 40)
        assert_compare EPUB::CFI::TemporalSpatialOffset.new(23.5, 30, 40), '<', EPUB::CFI::TemporalSpatialOffset.new(23.5, 30, 50)
        assert_compare EPUB::CFI::TemporalSpatialOffset.new(24, 30, 40), '>', EPUB::CFI::TemporalSpatialOffset.new(23.5, 100, 100)
      end
    end
  end

  class TestIdentify < self
    def setup
      @package_document = Nokogiri.XML(open('test/fixtures/book/OPS/ルートファイル.opf'))
    end

    def test_package_document
      assert_same @package_document.search('spine').first, epubcfi('/6').identify(@package_document)
      assert_same @package_document.search('itemref')[1], epubcfi('/6/4').identify(@package_document)
    end
  end

  private

  def epubcfi(string)
    EPUB::Parser::CFI.new.parse('epubcfi(' + string + ')')
  end
end
