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

  Rake::TestTask.new do |task|
    task.test_files = FileList['test/**/test_*.rb']
    task.warning = true
    task.options = '--no-show-detail-immediately --verbose'
  end

  desc 'Build test fixture EPUB file'
  task :build do
    input_dir  = 'test/fixtures/book'
    FileList["#{input_dir}/**/*"]
    sh "epzip #{input_dir}"
  end
end


YARD::Rake::YardocTask.new do |task|
  task.files = %w[- wiki/*.md]
end

desc "Build epub-parser-#{EPUB::Parser::VERSION}.gem into the pkg directory."
task :build => :yard do
  Bundler::GemHelper.new.build_gem
end

desc "Build and install epub-parser-#{EPUB::Parser::VERSION}.gem into system gems."
task :install => :yard do
  Bundler::GemHelper.new.install_gem
end

desc "Create tag v#{EPUB::Parser::VERSION} and build and push epub-parser-#{EPUB::Parser::VERSION}.gem to Rubygems"
task :release => :yard do
  Bundler::GemHelper.new.release_gem
end

Cucumber::Rake::Task.new
