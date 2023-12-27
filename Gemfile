source 'https://rubygems.org'
gemspec

if ENV['EPUB_MAKER_PATH']
  group :development do
    gem 'epub-maker', path: ENV["EPUB_MAKER_PATH"]
  end
end

if RUBY_PLATFORM.match /darwin/
  gem 'terminal-notifier'
end
