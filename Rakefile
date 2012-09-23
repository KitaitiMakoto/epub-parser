require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yard'
require 'cucumber'
require 'cucumber/rake/task'

task :default => 'test:default'

namespace :test do
  task :default => [:build, :test]

  Rake::TestTask.new do |task|
    task.test_files = FileList['test/**/test_*.rb']
    task.warning = true
    task.options = '--no-show-detail-immediately --verbose'
  end

  desc 'Build the test fixture EPUB'
  task :build do
    input_dir  = 'test/fixtures/book'
    output_dir = 'test/fixtures/'
    FileList["#{input_dir}/**/*"]
    sh "epzip #{input_dir}"
  end
end


YARD::Rake::YardocTask.new

Cucumber::Rake::Task.new
