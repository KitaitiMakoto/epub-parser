require 'bundler/gem_helper'
require 'rake/testtask'
require 'rake/clean'
require 'yard'
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

YARD::Rake::YardocTask.new

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
