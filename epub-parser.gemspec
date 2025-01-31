# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "epub/parser/version"

Gem::Specification.new do |s|
  s.name        = "epub-parser"
  s.version     = EPUB::Parser::VERSION
  s.authors     = ["KITAITI Makoto"]
  s.email       = ["KitaitiMakoto@gmail.com"]
  s.homepage    = "https://kitaitimakoto.gitlab.io/epub-parser/file.Home.html"
  s.summary     = %q{EPUB 3 Parser}
  s.description = %q{Parse EPUB 3 book loosely}
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.6'

  s.files         = `git ls-files`.split("\n")
                    .push('test/fixtures/book/OPS/ルートファイル.opf')
                    .push('test/fixtures/book/OPS/日本語.xhtml')
                    .push(Dir['docs/*.md'])
  s.files.reject! do |fn|
    ['"test/fixtures/book/OPS/\343\203\253\343\203\274\343\203\210\343\203\225\343\202\241\343\202\244\343\203\253.opf"', '"test/fixtures/book/OPS/\346\227\245\346\234\254\350\252\236.xhtml"'].include? fn
  end
  s.test_files    = s.files & Dir['{test,spec,features}/**/*.{rb,feature}']
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.metadata["yard.run"] = "yard"

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubygems-tasks'
  s.add_development_dependency 'zipruby'
  s.add_development_dependency 'rubyzip', '>= 2.0.0'
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'test-unit-rr'
  s.add_development_dependency 'test-unit-notify'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'gem-man'
  s.add_development_dependency 'ronn-ng'
  s.add_development_dependency 'epub-maker'
  s.add_development_dependency 'asciidoctor'
  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'oga', '>= 2.16'
  s.add_development_dependency 'packnga'
  s.add_development_dependency "steep"

  s.add_runtime_dependency 'archive-zip'
  s.add_runtime_dependency 'rexml'
  s.add_runtime_dependency 'addressable', '>= 2.3.5'
  s.add_runtime_dependency 'rchardet', '>= 1.6.1'
  s.add_runtime_dependency 'epub-cfi'
end
