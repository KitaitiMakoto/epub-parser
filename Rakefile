require 'bundler/gem_helper'
require 'rake/clean'
require 'rake/testtask'
require 'yard'
require 'rdoc/task'
require 'cucumber'
require 'cucumber/rake/task'
require 'epub/parser/version'

task :default => :test
task :test => 'test:default'

namespace :test do
  task :default => [:build, :test]

  desc 'Run all tests'
  task :all => [:build, :test, :cucumber]

  desc 'Build test fixture EPUB file'
  task :build => :clean do
    input_dir  = 'test/fixtures/book'
    sh "epzip #{input_dir}"
  end

  Rake::TestTask.new do |task|
    task.test_files = FileList['test/**/test_*.rb']
    task.warning = true
    task.options = '--no-show-detail-immediately --verbose'
  end

  Cucumber::Rake::Task.new
end

task :doc => 'doc:default'

namespace :doc do
  task :default => [:yard, :rdoc]

  YARD::Rake::YardocTask.new
  Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_files = FileList['lib/**/*.rb']
    rdoc.rdoc_files.include 'README.markdown'
    rdoc.rdoc_files.include 'MIT-LICENSE'
    rdoc.rdoc_files.include 'wiki/**/*.md'
  end
end

namespace :gem do
  desc "Build epub-parser-#{EPUB::Parser::VERSION}.gem into the pkg directory."
  task :build do
    Bundler::GemHelper.new.build_gem
  end

  desc "Build and install epub-parser-#{EPUB::Parser::VERSION}.gem into system gems."
  task :install do
    Bundler::GemHelper.new.install_gem
  end

  desc "Create tag v#{EPUB::Parser::VERSION} and build and push epub-parser-#{EPUB::Parser::VERSION}.gem to Rubygems"
  task :release do
    Bundler::GemHelper.new.release_gem
  end
end
