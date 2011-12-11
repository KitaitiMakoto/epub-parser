# -*- coding: utf-8 -*-
require File.expand_path 'helper', File.dirname(__FILE__)
require 'epub/parser/ocf'

class TestParser < Test::Unit::TestCase
  def setup
    @parser = Parser::OCF.new "test/fixtures/book"
  end

  def test_parse_container
    container = @parser.parse_container

    assert_equal 'OPS/ルートファイル.pdf', container.rootfile.full_path
  end

  def test_parse
    ocf = @parser.parse

p ocf

    pend
  end
end

