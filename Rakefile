require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yard'

task :default => :test

Rake::TestTask.new do |task|
  task.test_files = FileList['test/**/test_*.rb']
  ENV['TESTOPTS'] = '--no-show-detail-immediately --verbose'
end

YARD::Rake::YardocTask.new

namespace :sample do
  desc 'Build the text fixture EPUB'
  task :build do
    input_dir  = 'test/fixtures/book'
    output_dir = 'test/fixtures/'
    FileList["#{input_dir}/**/*"]
    sh "epzip #{input_dir}"
  end
end
