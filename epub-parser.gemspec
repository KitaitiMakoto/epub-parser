# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "epub/parser/version"

Gem::Specification.new do |s|
  s.name        = "epub-parser"
  s.version     = EPUB::Parser::VERSION
  s.authors     = ["KITAITI Makoto"]
  s.email       = ["KitaitiMakoto@gmail.com"]
  s.homepage    = "https://github.com/KitaitiMakoto/epub-parser"
  s.summary     = %q{EPUB 3 Parser}
  s.description = %q{Parse EPUB 3 book loosely}
  s.license     = 'MIT'

  # s.rubyforge_project = "epub-parser"

  s.files         = `git ls-files`.split("\n").push('test/fixtures/book/OPS/ルートファイル.opf')
  s.files.delete('"test/fixtures/book/OPS/\343\203\253\343\203\274\343\203\210\343\203\225\343\202\241\343\202\244\343\203\253.opf"')
  s.test_files    = `git ls-files -- {test,spec,features}/**/*.rb`.split("\n") 
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.has_rdoc = 'yard'

  s.add_development_dependency 'rubygems-test'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-doc'
  s.add_development_dependency 'test-unit-full'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'thin'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'gem-man'
  s.add_development_dependency 'ronn'
  s.add_development_dependency 'epzip'
  s.add_development_dependency 'epubcheck'
  s.add_development_dependency 'epub_validator'
  s.add_development_dependency 'aruba'

  s.add_runtime_dependency 'enumerabler'
  s.add_runtime_dependency 'zipruby'
  s.add_runtime_dependency 'nokogiri'
  s.add_runtime_dependency 'addressable'
end
