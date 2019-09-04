source 'https://rubygems.org'
gemspec

if ENV['EDGE_MAKER'] == '1'
  group :development do
    gem 'epub-maker', path: '../epub-maker'
  end
end

if RUBY_PLATFORM.match /darwin/
  gem 'terminal-notifier'
end
