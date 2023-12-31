source 'https://rubygems.org'
gemspec

group :development do
  if ENV['EPUB_MAKER_PATH']
    gem 'epub-maker', path: ENV["EPUB_MAKER_PATH"]
  end

  if RUBY_PLATFORM.match /darwin/
    gem 'terminal-notifier'
  end
end
