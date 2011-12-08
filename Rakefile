require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yard'

task :default => :test

Rake::TestTask.new do |task|
  task.test_files = FileList['test/**/test_*.rb']
  ENV['TESTOPTS'] = '--no-show-detail-immediately --verbose'
end

YARD::Rake::YardocTask.new
