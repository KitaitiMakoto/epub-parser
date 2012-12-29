require 'simplecov'
SimpleCov.start do
  add_filter '/test|deps/'
end

require 'test/unit/full'
require 'epub/parser'
