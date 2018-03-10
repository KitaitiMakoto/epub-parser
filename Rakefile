require 'rake/clean'
require 'rake/testtask'
require 'rubygems/tasks'
require 'yard'
require 'rdoc/task'
require 'epub/parser/version'
require 'zipruby'
require 'epub/maker'

task :default => :test
task :test => 'test:default'

namespace :test do
  task :default => [:build, :test]

  desc 'Run all tests'
  task :all => [:build, :test]

  desc 'Build test fixture EPUB file'
  task :build => :clean do
    input_dir  = 'test/fixtures/book'
    EPUB::Maker.archive input_dir
    small_file = File.read("#{input_dir}/OPS/case-sensitive.xhtml")
    Zip::Archive.open "#{input_dir}.epub" do |archive|
      archive.add_buffer 'OPS/CASE-SENSITIVE.xhtml', small_file.sub('small file name', 'LARGE FILE NAME')
    end
  end

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
    rdoc.rdoc_files.include 'README.markdown'
    rdoc.rdoc_files.include 'MIT-LICENSE'
    rdoc.rdoc_files.include 'docs/**/*.md'
  end
end

Gem::Tasks.new do |tasks|
  tasks.console.command = 'pry'
end
task :build => :clean
