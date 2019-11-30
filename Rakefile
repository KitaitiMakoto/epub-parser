require 'rake/clean'
require 'rake/testtask'
require 'rubygems/tasks'
require 'yard'
require 'rdoc/task'
require 'epub/parser/version'
require 'archive/zip'
require 'epub/maker'
require "tmpdir"

task :default => :test
task :test => 'test:default'

namespace :test do
  task :default => [:build, :test]

  desc 'Build test fixture EPUB file'
  task :build => [:clean, "test/fixtures/book.epub"]

  file "test/fixtures/book.epub" => "test/fixtures/book" do |task|
    EPUB::Maker.archive task.source
    small_file = File.read("#{task.source}/OPS/case-sensitive.xhtml")
    Dir.mktmpdir do |dir|
      upcase_file_path = File.join(dir, "CASE-SENSITIVE.xhtml")
      File.write upcase_file_path, small_file.sub('small file name', 'LARGE FILE NAME')
      Archive::Zip.archive task.name, upcase_file_path, path_prefix: "OPS"
    end
  end
  CLEAN.include "test/fixtures/book.epub"

  Rake::TestTask.new do |task|
    task.test_files = FileList['test/**/test_*.rb']
    task.warning = true
    task.options = '--no-show-detail-immediately --verbose'
  end
end

task :doc => 'doc:default'

namespace :doc do
  task :default => [:yard, :rdoc]

  YARD::Rake::YardocTask.new
  Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_files = FileList['lib/**/*.rb']
    rdoc.rdoc_files.include 'README.adoc'
    rdoc.rdoc_files.include 'CHANGELOG.adoc'
    rdoc.rdoc_files.include 'MIT-LICENSE'
    rdoc.rdoc_files.include 'docs/**/*.adoc'
    rdoc.rdoc_files.include 'docs/**/*.md'
  end
end

Gem::Tasks.new do |tasks|
  tasks.console.command = 'pry'
end
task :build => :clean
