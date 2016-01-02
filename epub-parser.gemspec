# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "epub/parser/version"

Gem::Specification.new do |s|
  s.name        = "epub-parser"
  s.version     = EPUB::Parser::VERSION
  s.authors     = ["KITAITI Makoto"]
  s.email       = ["KitaitiMakoto@gmail.com"]
  s.homepage    = "http://www.rubydoc.info/gems/epub-parser/file/docs/Home.markdown"
  s.summary     = %q{EPUB 3 Parser}
  s.description = %q{Parse EPUB 3 book loosely}
  s.license     = 'MIT'
  s.required_ruby_version = '> 2'

  s.files         = `git ls-files`.split("\n")
                    .push('lib/epub/parser/cfi.tab.rb')
                    .push('test/fixtures/book/OPS/ルートファイル.opf')
                    .push('test/fixtures/book/OPS/日本語.xhtml')
                    .push(Dir['docs/*.md'])
  s.files.reject! do |fn|
    ['"test/fixtures/book/OPS/\343\203\253\343\203\274\343\203\210\343\203\225\343\202\241\343\202\244\343\203\253.opf"', '"test/fixtures/book/OPS/\346\227\245\346\234\254\350\252\236.xhtml"'].include? fn
  end
  s.test_files    = s.files & Dir['{test,spec,features}/**/*.{rb,feature}']
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.has_rdoc = 'yard'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'zipruby'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-doc'
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'test-unit-rr'
  s.add_development_dependency 'test-unit-notify'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'gem-man'
  s.add_development_dependency 'ronn'
  s.add_development_dependency 'epzip'
  s.add_development_dependency 'racc'
  s.add_development_dependency 'nokogiri-diff'

  s.add_runtime_dependency 'archive-zip'
  s.add_runtime_dependency 'nokogiri', '~> 1.6'
  s.add_runtime_dependency 'addressable', '>= 2.3.5'
  s.add_runtime_dependency 'rchardet', '>= 1.6.1'
end
