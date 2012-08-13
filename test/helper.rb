require 'simplecov'
SimpleCov.start do
  add_filter '/test|vendor/'
end

gem 'test-unit'
require 'test/unit'
require 'test/unit/rr'
