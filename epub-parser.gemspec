# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "epub/parser/version"

Gem::Specification.new do |s|
  s.name        = "epub-parser"
  s.version     = EPUB::Parser::VERSION
  s.authors     = ["KITAITI Makoto"]
  s.email       = ["KitaitiMakoto@gmail.com"]
  s.homepage    = "https://gitorious.org/epub/parser"
  s.summary     = %q{EPUB 3 Parser}
  s.description = %q{Parse EPUB 3 book loosely}

  # s.rubyforge_project = "epub-parser"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/**/*.rb`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rubygems-test'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'test-unit', '~> 2'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'thin'
  s.add_development_dependency 'yard'

  s.add_runtime_dependency 'enumerabler'
  s.add_runtime_dependency 'nokogiri'
  s.add_runtime_dependency 'addressable'
end
