# -*- coding: utf-8 -*-
require File.expand_path 'helper', File.dirname(__FILE__)
require 'epub/parser/publication'

class TestParserPublication < Test::Unit::TestCase
  def setup
    @parser = Parser::Publication.new 'test/fixtures/book/OPS/ルートファイル.opf'
  end

  def test_parse_manifest
    manifest = @parser.parse_manifest

    pend
  end
end
