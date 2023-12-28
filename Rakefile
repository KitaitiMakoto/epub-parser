require 'rake/clean'
require 'rubygems/tasks'
require 'yard'
require 'rdoc/task'

task :default => :test

task :doc => 'doc:default'

namespace :doc do
  task :default => [:yard, :rdoc]

  YARD::Rake::YardocTask.new
  Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_files.include %w[
      lib/**/*.rb
      README.adoc
      CHANGELOG.adoc
      MIT-LICENSE
      docs/**/*.adoc
      docs/**/*.md
    ]
  end

  desc "Build man page for epubinfo command"
  file "man/epubinfo.1" => :ronn

  desc "Build HTML man page for epubinfo command"
  file "man/epubinfo.1.html" => :ronn

  task ronn: "man/epubinfo.1.ronn" do |t|
    sh "ronn #{t.source}"
  end
end

Gem::Tasks.new
task :build => :clean
