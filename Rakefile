require 'rake/clean'
require 'rake/testtask'
require 'rubygems/tasks'
require 'yard'
require 'rdoc/task'
require 'epub/parser/version'
require 'archive/zip'
require 'stringio'
require 'epub/maker'

task :default => :test
task :test => 'test:default'

namespace :test do
  task :default => [:build, :test]

  desc 'Run all tests'
  task :all => [:build, :test]

  desc 'Build test fixture EPUB file'
  task :build => :clean do
    Encoding.default_external = "UTF-8"
    input_dir  = 'test/fixtures/book'
    EPUB::Maker.archive input_dir
    small_file = File.read("#{input_dir}/OPS/case-sensitive.xhtml")
    File.open "#{input_dir}.epub" do |archive_in|
      File.open "#{input_dir}.epub.tmp", "w" do |archive_out|
        Archive::Zip.open archive_in, :r do |z_in|
          Archive::Zip.open archive_out, :w do |z_out|
            z_in.each do |entry|
              z_out << entry
            end
            entry = Archive::Zip::Entry::File.new("OPS/CASE-SENSITIVE.xhtml")
            entry.file_data = StringIO.new(small_file.sub('small file name', 'LARGE FILE NAME'))
            z_out << entry
          end
        end
      end
    end
    File.rename "#{input_dir}.epub.tmp", "#{input_dir}.epub"
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
