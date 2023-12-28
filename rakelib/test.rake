require 'rake/clean'
require 'rake/testtask'
require 'epub/maker'
require "tmpdir"
require 'archive/zip'

task :test => 'test:default'

namespace :test do
  task :default => [:test, :test_ocf_physical_container_zipruby, :test_ocf_physical_container_rubyzip]

  desc 'Build test fixture EPUB file'
  task :build => [:clean, "test/fixtures/book.epub"]

  file "test/fixtures/book.epub" => "test/fixtures/book" do |task|
    EPUB::Maker.archive task.source
    # We cannot include "CASE-SENSITIVE.xhtml" in Git repository because
    # macOS remove it or case-sensitive.xhtml from file system.
    small_file = File.read("#{task.source}/OPS/case-sensitive.xhtml")
    Dir.mktmpdir do |dir|
      upcase_file_path = File.join(dir, "CASE-SENSITIVE.xhtml")
      File.write upcase_file_path, small_file.sub('small file name', 'LARGE FILE NAME')
      Archive::Zip.archive task.name, upcase_file_path, path_prefix: "OPS"
    end
  end
  CLEAN.include "test/fixtures/book.epub"

  Rake::TestTask.new test: :build do |task|
    task.test_files = FileList['test/**/test_*.rb'].exclude "test/test_ocf_physical_container_*.rb"
    task.warning = true
    task.options = '--no-show-detail-immediately --verbose'
  end

  Rake::TestTask.new test_ocf_physical_container_zipruby: :build do |task|
    task.test_files = FileList["test/test_ocf_physical_container_zipruby.rb"]
    task.warning = true
    task.options = "--no-show-detail-immediately --verbose"
  end

  Rake::TestTask.new test_ocf_physical_container_rubyzip: :build do |task|
    task.test_files = FileList["test/test_ocf_physical_container_rubyzip.rb"]
    task.warning = true
    task.options = "--no-show-detail-immediately --verbose"
  end
end
